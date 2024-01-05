with orders as
  (
SELECT
  o.order_id_edw
, o.channel
, o.booked_date
, o.sold_date
, o.fulfillment_date
, o.amount_sold
FROM
  fact.orders o
left join
  fact.gl_transaction gt
  on gt.order_id_edw = o.order_id_edw
WHERE
   date_trunc(month,date(o.sold_date)) = '2023-12-01'
and (date_trunc(month,date(o.fulfillment_date)) is null or date_trunc(month,date(o.fulfillment_date)) = '2024-01-01')
)

SELECT distinct
  ol.order_id_edw
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
  orders o
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
  and net
order by 
  ol.order_id_edw