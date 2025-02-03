SELECT
  *
FROM
  fact.gl_transaction
WHERE
  posting_flag
  AND posting_period =  'Jan 2025'
  AND account_number = 4000
  AND net_amount < 0
--  and record_type = 'journalentry'
order by transaction_id_ns