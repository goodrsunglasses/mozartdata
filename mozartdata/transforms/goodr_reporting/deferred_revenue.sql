/*
This query is meant to find all transactions that occur in December but aren't fulfilled until the following month, thus per accounting standards we need to defer the revenue for those 
sales until the following year. 

Note: this code has been updated to allow for months other than december. 

*/
--Pull in december orders which generate revenue accounts 4****.
with period_orders as
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
, case when ol.record_type = 'cashsale' then gt.posting_period else null end as cs_posting_period
FROM
  fact.gl_transaction gt
left join
  fact.order_line ol
  on gt.transaction_id_ns = ol.transaction_id_ns
WHERE
   gt.posting_period = 'Jun 2023' --change period as needed
  and gt.posting_flag = true
  and gt.account_number like '4%'
),
  --find the earliest item fulfillment for the orders which generated revenue in december.
  if as
  (
    SELECT     
      po.order_id_edw
    , gt.posting_period
    , row_number() over (partition by po.order_id_edw order by gt.transaction_date) rn
    from
      period_orders po
    inner join
      fact.order_line ol
    on po.order_id_edw = ol.order_id_edw
    and ol.record_type = 'itemfulfillment'
    inner join
      fact.gl_transaction gt
      on gt.transaction_id_ns = ol.transaction_id_ns
    where posting_flag = true
  ),
  --find refunds which occur in future periods
  refunds as
  (
    select
      gt.order_id_edw
    , gt.posting_period
    , sum(gt.net_amount)
    , gt.transaction_date
    from
      period_orders po
    inner join
      fact.gl_transaction gt
    on po.order_id_edw = gt.order_id_edw
    and gt.record_type = 'cashrefund'
    group by
      all
  )
SELECT
  po.order_id_edw
, po.channel
, po.record_type
, po.transaction_number_ns 
, po.transaction_date revenue_transaction_date
, po.posting_period revenue_posting_period
, po.account_number
, po.net_amount
, o.has_refund
  --we pon't have insight into amazon/amazon prime shipping. so we recognize revenue at sale. Cabana is literal cash sales so there is no item fulfillment
, case when po.channel in ('Amazon','Amazon Prime','Amazon Canada','Cabana') then o.booked_date else o.fulfillment_date end fulfillment_date 
, case when po.channel in ('Amazon','Amazon Prime','Amazon Canada','Cabana') then d.posting_period else if.posting_period end if_posting_period
, r.posting_period as refund_posting_period
, case when po.cs_posting_period != r.posting_period then true else false end future_refund
, case when if_posting_period is null and future_refund then true else false end do_not_defer
FROM
  period_orders po
left join
  fact.orders o
  on po.order_id_edw = o.order_id_edw
left join
  if
  on po.order_id_edw = if.order_id_edw
  and if.rn = 1
left join
  dim.date d
  on d.date = o.booked_date
left join
  refunds r
  on po.order_id_edw = r.order_id_edw
order by 
  po.order_id_edw