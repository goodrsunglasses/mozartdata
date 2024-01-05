with dec_orders as
  (
SELECT DISTINCT
  gt.order_id_edw
FROM
  fact.gl_transaction gt
WHERE
   gt.posting_period = 'Dec 2023'
  and gt.posting_flag = true
  and gt.account_number like '4%'
)

SELECT distinct
  do.order_id_edw
, o.channel
, ol.transaction_number_ns
, ol.transaction_id_ns
, ol.record_type
, gt.transaction_date
, gt.account_number
, ga.account_full_name
, gt.net_amount
, gt.posting_period
, gt.posting_flag
FROM
  dec_orders do
inner join
  fact.orders o
  on do.order_id_edw = o.order_id_edw
inner join
  fact.order_line ol
  on o.order_id_edw = ol.order_id_edw
Left join
  fact.gl_transaction gt
  on ol.transaction_id_ns = gt.transaction_id_ns
left join
  dim.gl_account ga
  on gt.account_id_edw = ga.account_id_edw
where
  posting_flag = true
  --and ol.order_id_edw=  'G2789041'
  and gt.account_number like '4%'
order by 
  do.order_id_edw