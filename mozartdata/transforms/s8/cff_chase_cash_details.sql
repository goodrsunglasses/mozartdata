with
  chase_checking as
(
   SELECT
      gt.transaction_id_ns
    , gt.posting_period
    , gt.record_type
    , gt.transaction_date
    , gt.account_number
    , null as transaction_reference--concat(gt.record_type,': ',gt.transaction_number_ns) as transaction_reference
    , ga.account_display_name as account_name
    , v.name as vendor_name
    , cnm.company_name
    , gt.channel
   FROM
     fact.gl_transaction gt
   INNER JOIN
    dim.gl_account ga
    on gt.account_id_edw = ga.account_id_edw
   left join
    dim.vendors v
    on gt.customer_id_ns = v.vendor_id_ns
   left join
    fact.customer_ns_map cnm
    on gt.customer_id_ns = cnm.customer_id_ns
   WHERE
       gt.account_number in (1010)
   AND gt.posting_flag

 )
SELECT
  cc.transaction_id_ns
, cc.transaction_reference
, gt.posting_period
, gt.record_type
, t.accountbasednumber
, gt.transaction_date
, cc.account_number
, cc.account_name
, cc.vendor_name
, cc.company_name
, gt.channel
, gt.account_number as account_number_2
, ga.account_display_name as account_name_2
, null as transaction_reference_2--concat(gt.record_type,': ',gt.transaction_number_ns) as transaction_reference_2
, t.memo
, sum(gt.credit_amount) credit
, sum(gt.debit_amount) debit
, sum(gt.net_amount) net
FROM
fact.gl_transaction gt
inner join
  chase_checking cc
on gt.transaction_id_ns = cc.transaction_id_ns
inner join
  dim.gl_account ga
  on gt.account_id_edw = ga.account_id_edw
inner join
  netsuite.transaction t
  on gt.transaction_id_ns = t.id
WHERE
  gt.posting_flag
GROUP BY ALL