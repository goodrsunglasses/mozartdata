SELECT
  customer_id_ns,
  sum(net_amount)

FROM
  fact.gl_transaction
WHERE
  account_number LIKE '4%'
  and channel <> 'specialty'
  and posting_flag = 'true'
  and posting_period like '%2023'
group by 
  1