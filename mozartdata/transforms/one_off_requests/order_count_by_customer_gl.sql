SELECT
  customer_id_ns,
  COUNT(DISTINCT order_id_ns) AS distinct_orders

FROM
  fact.gl_transaction
WHERE
  account_number LIKE '4%'
  AND channel in ('Specialty','Key Account')
  and posting_flag = 'true'
--  and posting_period like '%2023'
group by 
  1