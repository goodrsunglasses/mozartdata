with ap_detail as
(
   SELECT
      gt.transaction_id_ns
    , gt.record_type
    , gtl.next_transaction_id_ns as transaction_reference
    , gt.transaction_date
    , gt.account_number
    , ga.account_display_name as account_name
    , v.name as vendor_name
    , cnm.company_name
    , gt.channel
    , gt.credit_amount
    , gt.net_amount
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
   left join
    fact.gl_transaction_link gtl
    on gtl.transaction_id_ns = gt.transaction_id_ns
   WHERE
       gt.account_number in (2000)
   AND gt.posting_flag
   AND gt.credit_amount != 0 --only capture transactions that add to AP
 )
SELECT
  gt.transaction_line_id  
, ap.transaction_id_ns
, ap.transaction_reference
, gt.posting_period
, acct.period_end_date
, gt.record_type
, t.accountbasednumber
, gt.transaction_date
, ap.account_number
, ap.account_name
, ap.vendor_name
, ap.company_name
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
  ap_detail ap
on gt.transaction_id_ns = ap.transaction_id_ns
inner join
  dim.gl_account ga
  on gt.account_id_edw = ga.account_id_edw
inner join
  netsuite.transaction t
  on gt.transaction_id_ns = t.id
left join
  dim.accounting_period acct
  on acct.posting_period = gt.posting_period
WHERE
  gt.posting_flag
  and gt.posting_period like '%24'
GROUP BY ALL
ORDER BY 1