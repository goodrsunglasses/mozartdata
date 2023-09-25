/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per GL account.
This transform creates a GL account dimension that transforms Netsuites Account table into Goodr's EDW.

joins: 
self joins to account to pull the parent account number

aliases: 
tal = transactionaccountingline
tran = transaction
ap = accountingperiod

createdate convert to America/Los_Angeles
use createdate converted instead of trandate
*/
    select
      concat(transaction,'_',transactionline) as transaction_line_id
    , tran.custbody_goodr_shopify_order order_number
    , tal."ACCOUNT" as account_id_ns
    , channel.name as channel
    , tran.trandate as date_transaction
    , CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) as date_posted
    -- , case 
    --   when channel.name = 'Amazon' then tran.trandate
    --   else CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) 
    --   end as date_gl
    , case when tal.posting = 'T' then true else false end posting_flag
    , ap.periodname as posting_period
    , sum(coalesce(tal.amount,0)) as amount_transaction
    , sum(coalesce(credit,0)) as  amount_credit
    , sum(coalesce(debit,0)) as amount_debit
    , sum(coalesce(netamount,0)) as amount_net
    , abs(sum(coalesce(tal.amount,0))) as amount_transaction_positive
    from
      netsuite.transactionaccountingline tal
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
    , case when tal.posting = 'T' then true else false end