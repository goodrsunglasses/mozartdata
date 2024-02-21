WITH cte_tran_pp AS (
  SELECT 
    order_id_edw,
    gt.transaction_number_ns,
    posting_period,
    COUNT(DISTINCT posting_period) OVER (PARTITION BY order_id_edw) AS distinct_posting_periods
  FROM 
    fact.gl_transaction gt
  where 
    (posting_period like '%24' or posting_period in ( 'Dec 2023'))
    and posting_flag = true
    and gt.transaction_number_ns not like 'CR%'
) 
SELECT 
  order_id_edw,
  transaction_number_ns,
  posting_period
FROM 
  cte_tran_pp
WHERE 
  distinct_posting_periods > 1
  and order_id_edw is not null
  and transaction_number_ns is not null
order by order_id_edw