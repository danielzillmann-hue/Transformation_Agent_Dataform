# Generated Dataform project

This repo was generated automatically from Oracle pipeline XMLs by
intelia's Lineage & Usage Agents. It is a 1:1 translation of the
legacy ETL into BigQuery + Dataform.

## Target environment

- **GCP project**: `transformation-agent-demo`
- **Location**: `australia-southeast1`
- **Default dataset**: `migration_demo`
- **Source dataset** (Oracle replication target): `migration_raw`

## Layout

- `workflow_settings.yaml` — project-level config
- `definitions/sources.sqlx` — `type: "declaration"` blocks for every
  external table the pipelines read from
- `definitions/<pipeline>.sqlx` — one per materialised table
- `definitions/operations/<op>.sqlx` — post-load DML statements
  (UPDATE/DELETE/MERGE preserved from the original pipelines)

## Pipelines produced (28)

- `definitions/accounts_summary.sqlx`
- `definitions/active_member_addresses.sqlx`
- `definitions/calculate_monthly_fees.sqlx`
- `definitions/contributions_report.sqlx`
- `definitions/core_account_summary.sqlx`
- `definitions/core_fee_aggregation.sqlx`
- `definitions/core_tax_liability.sqlx`
- `definitions/current_balances.sqlx`
- `definitions/daily_transactions.sqlx`
- `definitions/eom_fees_report.sqlx`
- `definitions/external_enrichment.sqlx`
- `definitions/fact_regulatory_audit.sqlx`
- `definitions/fee_deductions.sqlx`
- `definitions/final_accounts_extract.sqlx`
- `definitions/final_fee_extract.sqlx`
- `definitions/final_tax_extract.sqlx`
- `definitions/investment_allocations.sqlx`
- `definitions/investment_performance.sqlx`
- `definitions/member_risk_profile.sqlx`
- `definitions/members_extract.sqlx`
- `definitions/pandas_to_oracle.sqlx`
- `definitions/pension_payments.sqlx`
- `definitions/stg_accounts.sqlx`
- `definitions/stg_audit_master.sqlx`
- `definitions/stg_daily_metrics.sqlx`
- `definitions/stg_raw_fees.sqlx`
- `definitions/stg_recent_fees.sqlx`
- `definitions/tax_reporting.sqlx`

## External sources required (10)

These tables must already exist in `migration_raw` before the
pipelines run. They're declared (not built) by Dataform.

- `account_investments`
- `account_types`
- `accounts`
- `investment_options`
- `market_benchmarks`
- `member_addresses`
- `members`
- `tax_brackets`
- `transactions`
- `vw_member_risk_profile`

## Post-load operations (3)

- `definitions/operations/regulatory_audit_compliance_flag_anomalies.sqlx`
- `definitions/operations/regulatory_audit_compliance_flag_anomalies_low.sqlx`
- `definitions/operations/update_account_status_mark_inactive.sqlx`

## Validation

All 41 files passed structural validation (refs resolve, SQL parses, no cycles).

## Running

```bash
dataform compile
dataform run
```
