with dec_orders as
  (
SELECT
  gt.channel
, gt.order_id_edw
, gt.transaction_number_ns
, gt.account_number
, gt.net_amount
, ol.record_type
, gt.posting_period
, gt.transaction_date
FROM
  fact.gl_transaction gt
left join
  fact.order_line ol
  on gt.transaction_id_ns = ol.transaction_id_ns
WHERE
   gt.posting_period = 'Dec 2023'
  and gt.posting_flag = true
  and gt.account_number like '4%'
),
  if as
  (
    SELECT     
      do.order_id_edw
    , gt.posting_period
    , row_number() over (partition by do.order_id_edw order by gt.transaction_date) rn
    from
      dec_orders do
    inner join
      fact.order_line ol
    on do.order_id_edw = ol.order_id_edw
    and ol.record_type = 'itemfulfillment'
    inner join
      fact.gl_transaction gt
      on gt.transaction_id_ns = ol.transaction_id_ns
    where posting_flag = true
  )
SELECT
  do.order_id_edw
, do.channel
, do.record_type
, do.transaction_number_ns 
, do.transaction_date revenue_transaction_date
, do.posting_period revenue_posting_period
, do.account_number
, do.net_amount
, case when do.channel in ('Amazon','Amazon Prime','Cabana') then o.booked_date else o.fulfillment_date end fulfillment_date
, case when do.channel in ('Amazon','Amazon Prime','Cabana') then d.posting_period else if.posting_period end if_posting_period 
-- , o.channel
-- , ol.transaction_number_ns
-- , ol.transaction_id_ns
-- , ol.record_type
-- , gt.transaction_date
-- , gt.account_number
-- , ga.account_full_name
-- , gt.net_amount
-- , gt.posting_period
-- , gt.posting_flag
FROM
  dec_orders do
left join
  fact.orders o
  on do.order_id_edw = o.order_id_edw
left join
  if
  on do.order_id_edw = if.order_id_edw
  and if.rn = 1
left join
  dim.date d
  on d.date = o.booked_date
-- inner join
--   fact.order_line ol
--   on o.order_id_edw = ol.order_id_edw
-- Left join
--   fact.gl_transaction gt
--   on ol.transaction_id_ns = gt.transaction_id_ns
-- left join
--   dim.gl_account ga
--   on gt.account_id_edw = ga.account_id_edw
-- where
--   posting_flag = true
--   --and ol.order_id_edw=  'G2789041'
--   and gt.account_number like '4%'
order by 
  do.order_id_edw