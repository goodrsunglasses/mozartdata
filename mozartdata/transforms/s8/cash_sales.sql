with gabbys as (
  SELECT
  posting_period,
  transaction_date,
  transaction_number_ns,
  channel,
  net_amount,
  custbody_boomi_orderid,
  account_number
FROM
  fact.gl_transaction gl
  LEFT JOIN netsuite.transaction nst ON nst.id = gl.transaction_id_ns
WHERE
  posting_flag = TRUE
  and posting_period = 'Jun 2024'
  and account_number like '4%'
)

select * from gabbys
where channel = 'Goodr.com'
and account_number = 4000
and record_type = 'cashsale'