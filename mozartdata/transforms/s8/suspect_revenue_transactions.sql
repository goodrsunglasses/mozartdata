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
  --  AND posting_period = 'Feb 2025'
  AND posting_period LIKE '%2025'
  --  and channel = 'Key Accounts'
  --  and customer_name = 'REI'

ORDER BY
    transaction_date desc,
  record_type
  ------------------------  item fulfillments impacting 4000?
SELECT
  channel,
  posting_period,
  record_type,
  account_number,
  transaction_number_ns,
  order_id_edw,
  net_amount
FROM
  fact.gl_transaction
WHERE
  posting_flag
  AND account_number LIKE '4%'
  AND posting_period = 'Feb 2025'
  AND channel = 'Key Accounts'
  AND record_type = 'itemfulfillment'
ORDER BY
  transaction_number_ns
  --------
SELECT
  transaction_number_ns,
  sum(net_amount),
  record_type,
  account_number
FROM
  fact.gl_transaction
WHERE
  channel = 'Key Accounts'
  AND posting_flag
  AND customer_id_edw = '2307daba6a0c8d1a9e460dc76ef0faa0'
  AND posting_period = 'Feb 2025'
GROUP BY
  ALL
  -----------