# Raw-layer replication setup

The transformation pipelines this project generates read from the
`transformation-agent-demo.migration_raw` BigQuery dataset. That dataset is the **raw
layer** — replicated from the Oracle warehouse — and the agents
declare these tables but do *not* populate them. Pick one of the
options below to bring data over.

## Tables required

The pipelines reference 10 source tables:

  - account_investments
  - account_types
  - accounts
  - investment_options
  - market_benchmarks
  - member_addresses
  - members
  - tax_brackets
  - transactions
  - vw_member_risk_profile

The DDL for each is in [`raw_schema.sql`](raw_schema.sql). Run that
once to provision the empty target tables:

```bash
bq query --project_id=transformation-agent-demo --location=australia-southeast1 --use_legacy_sql=false \
  < bootstrap/raw_schema.sql
```

## Option A — Datastream (recommended for production)

Datastream is the GCP-native, low-latency Oracle CDC service.

1. Enable the API:
   ```bash
   gcloud services enable datastream.googleapis.com
   ```
2. Create connection profiles for the source (Oracle) and destination
   (BigQuery). Replace `<HOST>` / `<USER>` / `<PASS>` with your values:
   ```bash
   gcloud datastream connection-profiles create oracle-source \
     --location=australia-southeast1 --type=oracle --display-name="Source Oracle" \
     --oracle-hostname=<HOST> --oracle-port=1521 \
     --oracle-username=<USER> --oracle-password=<PASS> \
     --oracle-database-service=<SERVICE>

   gcloud datastream connection-profiles create bq-target \
     --location=australia-southeast1 --type=bigquery --display-name="Target BigQuery"
   ```
3. Create the stream (initial backfill + ongoing CDC):
   ```bash
   gcloud datastream streams create oracle-to-bq-stream \
     --location=australia-southeast1 \
     --source=oracle-source --destination=bq-target \
     --oracle-source-config="<json-with-tables-listed>" \
     --bigquery-destination-config="data_freshness=900s,dataset=migration_raw" \
     --backfill-all
   ```

The full Oracle source config JSON can list specific schemas/tables
('account_investments', 'account_types', 'accounts', 'investment_options', 'market_benchmarks', 'member_addresses', 'members', 'tax_brackets', 'transactions', 'vw_member_risk_profile') so only what the pipelines need gets replicated.

## Option B — Manual `bq load` (one-shot for a demo / POC)

For a Tuesday-style demo where you just need data once, dump the source
tables to CSV/Parquet and load them:

```bash
# Per table, repeat with appropriate names:
bq load --autodetect --source_format=CSV \
  transformation-agent-demo:migration_raw.accounts \
  gs://your-bucket/oracle-export/accounts.csv
```

A small Python script using `oracledb` + `google-cloud-bigquery` can
loop over the tables in one pass — see the inventory agent's source for
the connection pattern.

## Option C — BigQuery federation (no copy)

Use BQ external tables that query Oracle live via Cloud SQL. Limited
performance but no replication infrastructure needed:

```sql
CREATE EXTERNAL TABLE `transformation-agent-demo.migration_raw.accounts`
WITH CONNECTION `transformation-agent-demo.australia-southeast1.oracle-conn`
OPTIONS (
  format = 'oracle',
  uris = ['oracle://<HOST>:1521/<SERVICE>'],
  source_table = 'ORACLE_SCHEMA.ACCOUNTS'
);
```

This avoids the schema bootstrap entirely — the external table inherits
Oracle's schema. Trade-off is per-query latency.

---

After whichever path you pick, verify with:

```sql
SELECT table_name, row_count
FROM `transformation-agent-demo.migration_raw.INFORMATION_SCHEMA.TABLES`
ORDER BY table_name;
```

…then `dataform run` will produce the downstream tables.
