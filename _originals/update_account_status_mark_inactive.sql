UPDATE accounts
                SET status = 'Inactive'
                WHERE account_id IN (
                    SELECT account_id
                    FROM accounts
                    WHERE open_date < SYSDATE - 365
                )