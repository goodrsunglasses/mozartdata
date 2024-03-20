-- transaction_number_nsWITH cte_tran_pp AS (
--   SELECT DISTINCT
--     order_id_edw,
--     gt.transaction_number_ns,
--     gt.posting_period,
--     month as posting_month,
--     COUNT(DISTINCT gt.posting_period) OVER (PARTITION BY order_id_edw) AS distinct_posting_periods
--   FROM 
--     fact.gl_transaction gt
--     left join dim.date date on gt.posting_period = date.posting_period
--   where 
--     gt.posting_period like '%24'
--     and (posting_month = month(current_date()) or posting_month = month(current_date())-1)
--     and posting_flag = true
--     and gt.transaction_number_ns not like 'CR%'
-- ), 
WITH sales as
(
  select
    gt.order_id_edw
  , gt.order_id_ns
  , gt.transaction_number_ns
  , ol.record_type
  -- , gt.account_number
  , gt.transaction_date
  , gt.posting_period
  , sum(gt.net_amount) net_amount
  from
    fact.gl_transaction gt
  left join
    fact.order_line ol
    on gt.transaction_id_ns = ol.transaction_id_ns
  where
    gt.account_number between 4000 and 4999
  and posting_flag
  GROUP BY
    gt.order_id_edw
  , gt.order_id_ns
  , gt.transaction_number_ns
  , ol.record_type
  -- , gt.account_number
  , gt.transaction_date
  , gt.posting_period
), cogs as
(
    select
    gt.order_id_edw
  , gt.order_id_ns
  , gt.transaction_number_ns
  , gt.account_number
  , gt.transaction_date
  , gt.posting_period
  , sum(gt.net_amount) net_amount
  from
    fact.gl_transaction gt
  where
    gt.account_number = 5000
  and posting_flag
  GROUP BY
    gt.order_id_edw
  , gt.order_id_ns
  , gt.transaction_number_ns
  , gt.account_number
  , gt.transaction_date
  , gt.posting_period

  
)
SELECT DISTINCT
  s.order_id_edw
, s.order_id_ns
, s.record_type
, s.transaction_number_ns sales_transaction_number
, s.posting_period as sales_posting_period
, s.net_amount sales_amount
, c.transaction_number_ns cogs_transaction_number
, c.posting_period cogs_posting_period
, c.net_amount cogs_amount
FROM
  sales s
LEFT JOIN
  cogs c
  ON s.order_id_edw = c.order_id_edw
WHERE
  s.posting_period != c.posting_period
AND s.posting_period like '%24'
ORDER BY
  s.order_id_edw
-- SELECT 
--   order_id_edw,
--   transaction_number_ns,
--   posting_period
-- FROM 
--   cte_tran_pp
-- WHERE 
--   distinct_posting_periods > 1
--   and order_id_edw is not null
--   and transaction_number_ns is not null
-- order by order_id_edw

-- select * from dim.gl_account where account_number like '4%'