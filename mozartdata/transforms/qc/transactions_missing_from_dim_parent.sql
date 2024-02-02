/*
This is the list of transactions in NS which are not correctly associated as parent child
As of 2/2/2024 There are 439 transactions out of 2,095,374. These do NOT include cash refunds, estimates (quotes) or vendor bills

*/
SELECT distinct
  oi.order_id_ns
, oi.transaction_id_ns
, oi.record_type
, oi.createdfrom
FROM
  staging.order_item_detail oi
left join
  dim.parent_transactions pt
  on oi.transaction_id_ns = pt.transaction_id_ns
where
  pt.transaction_id_ns is null
and oi.record_type not in ('cashrefund','estimate','vendorbill')
order by
  transaction_id_ns