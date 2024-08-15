SELECT
  posting_period,
  transaction_date,
  transaction_number_ns,
  channel,
  net_amount,
  custbody_boomi_orderid,
  account_number,
  record_type
FROM
  fact.gl_transaction gl
  LEFT JOIN netsuite.transaction nst ON nst.id = gl.transaction_id_ns
WHERE
  posting_flag
  and posting_period in ('Jun 2024', 'Jul 2024')
  and (account_number like '4%' or account_number = '2420')
  and channel = 'Goodr.com'