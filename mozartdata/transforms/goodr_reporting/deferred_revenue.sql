/*
This query is meant to find all transactions that occur in December but aren't fulfilled until the following month, thus per accounting standards we need to defer the revenue for those 
sales until the following year. 

Note: this code has been updated to allow for months other than december. 

Code fully revised to include all revenue accounts for the given period. There was an issue that not all refunds were showing up in the given period, because we were only looking at SALES in that period.

*/
WITH
  revenue_transactions AS
    (
      SELECT
        gt.order_id_edw
      , gt.order_id_ns
      , gt.channel
      , gt.transaction_id_ns
      , gt.record_type
      , gt.account_number
      , ga.account_display_name
      , gt.transaction_number_ns
      , gt.transaction_date
      , gt.posting_period
      , sum(gt.net_amount) net_amount
      FROM
        fact.gl_transaction gt
      INNER JOIN
        dim.gl_account ga
        ON gt.account_id_edw = ga.account_id_edw
      WHERE
          gt.account_number like '4%'
      AND gt.posting_flag = TRUE
      AND gt.posting_period = 'Jul 2023'
      GROUP BY ALL
      )
, cs_inv as
  (
    select
      rt.order_id_edw
    , rt.order_id_ns
    , rt.channel
    , rt.transaction_id_ns
    , rt.transaction_number_ns
    , rt.transaction_date
    , rt.posting_period
    , rt.account_number
    , sum(rt.net_amount)
    from
      revenue_transactions rt
    where
      rt.record_type in ('cashsale','invoice')
    group by all
  )
, distinct_rt as
  (
    select distinct order_id_edw, order_id_ns, channel from revenue_transactions
  )
, cs_cogs as
  (
    select
      rt.order_id_edw
    , rt.order_id_ns
    , gt.posting_period
    , ap.period_start_date
    , sum(gt.net_amount) cogs
    from
      distinct_rt rt
    left join
      fact.gl_transaction gt
      on rt.order_id_edw = gt.order_id_edw
    left join
      dim.accounting_period ap
      on gt.posting_period = ap.posting_period
    where
      gt.record_type in ('cashsale')
    and gt.account_number = 5000
    and gt.posting_flag
    and rt.channel in ('Amazon Canada','Amazon','Cabana')
    group by all
  )
, refunds as
  (
    select
      rt.order_id_edw
    , rt.order_id_ns
    , gt.transaction_id_ns
    , ap.period_start_date
    , gt.posting_period
    , sum(case
        when gt.account_number between 4210 and 4299 then gt.net_amount
        when gt.account_number = 4110 then gt.credit_amount
        when gt.account_number in (4000, 4050) then gt.debit_amount * -1 --Some refunds are reversing revenue accounts instead of adding to refund accounts (42*)
        else 0 end) ref_amount
    from
      distinct_rt rt
    left join
      fact.gl_transaction gt
      on rt.order_id_edw = gt.order_id_edw
    left join
      dim.accounting_period ap
      on gt.posting_period = ap.posting_period
    where
      gt.record_type in ('cashrefund')
    and gt.posting_flag
    and gt.account_number>=2000
    group by all
  )
, item_fulfillment as
(
    select distinct
      rt.order_id_edw
    , rt.order_id_ns
    , gt.posting_period
    , ap.period_start_date
    , gt.account_number
    , sum(gt.net_amount) cogs
    from
      distinct_rt rt
    left join
      fact.gl_transaction gt
      on rt.order_id_edw = gt.order_id_edw
    left join
      dim.accounting_period ap
      on gt.posting_period = ap.posting_period
    where
      gt.record_type in ('itemfulfillment')
    and gt.account_number = 5000
    and gt.posting_flag
    group by all
  ),
order_status as
(
  SELECT distinct
    rt.order_id_edw
  , ol.transaction_status_ns as order_status
  FROM
    revenue_transactions rt
  left join
    fact.order_line ol
  on rt.order_id_edw = ol.order_id_edw
  and ol.record_type = 'salesorder'
),
first_if as
(
  select
    order_id_edw
  , order_id_ns
  , posting_period
  , cogs
  from
    item_fulfillment
  QUALIFY row_number() over (PARTITION BY order_id_ns order by period_start_date asc) =1
),
  second_if as
(
  select
    order_id_edw
  , order_id_ns
  , posting_period
  , cogs
  from
    item_fulfillment
  QUALIFY row_number() over (PARTITION BY order_id_ns order by period_start_date asc) =2
)
,
  third_if as
(
  select
    order_id_edw
  , order_id_ns
  , posting_period
  , cogs
  from
    item_fulfillment
  QUALIFY row_number() over (PARTITION BY order_id_ns order by period_start_date asc) =3
),
first_ref as
(
  select
    order_id_edw
  , order_id_ns
  , posting_period
  , ref_amount
  from
    refunds
  QUALIFY row_number() over (PARTITION BY order_id_ns order by period_start_date asc) =1
),
  second_ref as
(
select
    order_id_edw
  , order_id_ns
  , posting_period
  , ref_amount
  from
    refunds
  QUALIFY row_number() over (PARTITION BY order_id_ns order by period_start_date asc) =2
)
SELECT
  rt.order_id_edw
, rt.order_id_ns
, os.order_status
, rt.channel
, rt.transaction_id_ns
, rt.transaction_number_ns
, rt.transaction_date
, rt.posting_period
, rt.record_type
, rt.account_number
, rt.net_amount
, case when (cc.posting_period = fif.posting_period or fif.posting_period is null) then cc.posting_period else fif.posting_period end first_if_posting_period
, case when (cc.posting_period = fif.posting_period or fif.posting_period is null) then cc.cogs else fif.cogs end first_if_cogs
, sif.posting_period second_if_posting_period
, sif.cogs second_if_cogs
, tif.posting_period third_if_posting_period
, tif.cogs third_if_cogs
, fr.posting_period first_refund_posting_period
, fr.ref_amount first_refund_amount
, sr.posting_period second_refund_posting_period
, sr.ref_amount second_refund_amount
-- sum(net_amount)
FROM
  revenue_transactions rt
left join
  first_ref fr
  on rt.order_id_edw = fr.order_id_edw
left join
  second_ref sr
  on rt.order_id_edw = sr.order_id_edw
left join
  first_if fif
  on rt.order_id_edw = fif.order_id_edw
left join
  second_if sif
  on rt.order_id_edw = sif.order_id_edw
left join
  third_if tif
  on rt.order_id_edw = tif.order_id_edw
left join
  cs_cogs cc
  on rt.order_id_edw = cc.order_id_edw
left join
  order_status os
  on rt.order_id_edw = os.order_id_edw