WITH cte_tran_pp AS (
  SELECT DISTINCT
    order_id_edw,
    gt.transaction_number_ns,
    gt.posting_period,
    month as posting_month,
    COUNT(DISTINCT gt.posting_period) OVER (PARTITION BY order_id_edw) AS distinct_posting_periods
  FROM 
    fact.gl_transaction gt
    left join dim.date date on gt.posting_period = date.posting_period
  where 
    gt.posting_period like '%24'
    and (posting_month = month(current_date()) or posting_month = month(current_date())-1)
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