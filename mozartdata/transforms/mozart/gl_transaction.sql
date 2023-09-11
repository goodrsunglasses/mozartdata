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
-- , tran.actualshipdate as date_ship_actual
-- , tran.startdate as date_start
-- , tran.enddate as date_end
, CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) as date_posted
, case 
  when channel.name = 'Amazon' then tran.trandate
  else CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) 
  end as date_gl
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
left join 
  netsuite.customrecord_cseg7 channel 
  on tran.cseg7 = channel.id
left join
  netsuite.paymentevent pe
  on pe.doc = tran.id
-- where
--   order_number = 'G1899334'
  --a.issummary = 'F' and a.acctnumber like '4%'
group by
 concat(transaction,'_',transactionline)
, tran.custbody_goodr_shopify_order
, tal."ACCOUNT"
, channel.name
, tran.trandate
, pe.eventdate
  )
select
  date_trunc('MONTH',gt.date_gl)::date
, gt.order_number
, gt.date_gl
, gt.date_transaction
-- , date_ship_actual
-- , date_start
-- , date_end
, gt.date_posted
, ga.account_number
, ga.account_full_name
, gt.channel
, ga.summary_flag
, sum(credit_amount) credit_total
, sum(debit_amount) debit_total
, sum(net_amount) net_total
, sum(transaction_amount) amount_total
from
  gl_transactions gt
inner join
  dim.gl_account ga
  on gt.account_id_ns = ga.account_id_ns
 where
   -- date_trunc('MONTH',gt.date_gl)::date = '2023-01-01'
  account_number like '4%'
  --and order_number = '112-0392117-1829033'
--  and date_trunc('MONTH',gt.date_ship_actual)::date = '2023-01-01'
  --and channel = 'Global'
 --and gt.order_number = '114-8687610-3720232'
group by
--  date_transaction
  date_trunc('MONTH',gt.date_posted)::date
, gt.order_number
, gt.date_gl
, gt.date_transaction
, gt.date_posted
, ga.summary_flag
, account_full_name
--   , date_ship_actual
-- , date_start
-- , date_end
, gt.channel
, ga.account_number
order by channel asc, account_number asc
-- --select * from netsuite.transaction where id='1691860'
-- select a."ACCOUNT", sum(amount),sum(credit) from netsuite.transactionaccountingline a where transaction='1691860' group by 1
--   select * from netsuite.transactionaccountingline a where transaction='1691860' --group by 1
--     select * from netsuite.transaction a where id='1691860' --group by 1
-- select * from netsuite."ACCOUNT" where id in (268,117)
-- select * from netsuite.transaction where id = '9380568'
-- select * from dim.orders where order_id_ns = 'G1882331'

-- SELECT * FROM netsuite.customrecord_nbsabr_gltransaction

-- SELECT * FROM netsuite.transactionaccountingline



--SELECT * FROM dim.gl_account