/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per GL account.
This transform creates a GL account dimension that transforms Netsuites Account table into Goodr's EDW.

joins: 
self joins to account to pull the parent account number

aliases: 
tal = transactionaccountingline
a = account
tran = transaction
ap = accountingperiod
gt = gl_transactions CTE

createdate convert to America/Los_Angeles
use createdate converted instead of trandate
*/
with
  gl_transactions as
  ( 
    select
      concat(transaction,'_',transactionline) as transaction_line_id
    , tran.custbody_goodr_shopify_order order_number
    , tal."ACCOUNT" as account_id_ns
    , channel.name as channel
    , tran.trandate as date_transaction
    , CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) as date_posted
    , case 
      when channel.name = 'Amazon' then tran.trandate
      else CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) 
      end as date_gl
    , case when tal.posting = 'T' then 1 else 0 end posting_flag
    , ap.periodname as posting_period
    , sum(tal.amount) as transaction_amount
    , sum(credit) as  credit_amount
    , sum(debit) as debit_amount
    , sum(netamount) as net_amount
    , abs(sum(tal.amount)) as transaction_positive_amount
    from
      netsuite.transactionaccountingline tal
    inner join
      netsuite."ACCOUNT" a
      on tal."ACCOUNT" = a.id
    inner join
      netsuite.transaction tran
      on tal.transaction = tran.id
    inner join
      netsuite.accountingperiod ap
      on tran.postingperiod = ap.id
    left join 
      netsuite.customrecord_cseg7 channel 
      on tran.cseg7 = channel.id
    left join
      netsuite.paymentevent pe
      on pe.doc = tran.id
    group by
     concat(transaction,'_',transactionline)
    , tran.custbody_goodr_shopify_order
    , tal."ACCOUNT"
    , channel.name
    , tran.trandate
    , pe.eventdate
    , ap.periodname
    , case when tal.posting = 'T' then 1 else 0 end
  )
select
  gt.order_number
, gt.date_gl
, gt.date_transaction
, gt.date_posted
, ga.account_number
, ga.account_full_name
, ga.account_parent_number
, ga.account_parent_number_display_name
, gt.channel
, ga.summary_flag
, gt.posting_period
, gt.posting_flag
, sum(coalesce(credit_amount,0)) credit_total
, sum(coalesce(debit_amount,0)) debit_total
, sum(coalesce(net_amount,0)) net_total
, sum(coalesce(transaction_amount,0)) amount_total
from
  gl_transactions gt
inner join
  dim.gl_account ga
  on gt.account_id_ns = ga.account_id_ns
 where
  --
  account_number like '4%'
  and gt.posting_period = 'Jan 2023'
group by
  date_transaction
, gt.order_number
, gt.date_gl
, gt.date_transaction
, gt.date_posted
, ga.summary_flag
, ga.account_full_name
, ga.account_parent_number
, ga.account_parent_number_display_name
, gt.posting_period
, gt.channel
, ga.account_number
, gt.posting_flag
order by date_transaction
-- --select * from netsuite.transaction where id='1691860'
-- select a."ACCOUNT", sum(amount),sum(credit) from netsuite.transactionaccountingline a where transaction='1691860' group by 1
--   select * from netsuite.transactionaccountingline a where transaction='1691860' --group by 1
--     select * from netsuite.transaction a where id='1691860' --group by 1
-- select * from netsuite."ACCOUNT" where id in (268,117)
-- select * from netsuite.transaction where id = '9380568'
-- select * from dim.orders where order_id_ns = 'G1882331'

-- SELECT * FROM netsuite.customrecord_nbsabr_gltransaction

-- SELECT * FROM netsuite.transactionaccountingline

-- select * from netsuite.accountingperiod

-- select a.* from netsuite.transaction t inner join netsuite.accountingperiod a on t.postingperiod = a.id

--SELECT * FROM dim.gl_account