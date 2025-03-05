----- hidden JEs?
SELECT
  channel, 
  posting_period,
  record_type,
  account_number,
  transaction_date,
  transaction_number_ns,
  --  customer_id_edw,
    customer_name,
  net_amount
FROM
  fact.gl_transaction
  LEFT JOIN fact.customer_ns_map USING (customer_id_edw)
WHERE
  posting_flag
  AND account_number LIKE '4%'
  AND record_type NOT IN (
    'cashsale',
    'invoice',
    'customtransactionloyalty_program_trans',
    'cashrefund',
    'creditmemo',
    'journalentry'
  )

  AND posting_period LIKE '%2025'