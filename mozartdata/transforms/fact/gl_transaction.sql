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
tl = transactionline
ap = accountingperiod
channel = cseg7 aka channel
pe = paymentevent

createdate convert to America/Los_Angeles
use createdate converted instead of trandate
*/
    select
      concat(tal.transaction,'_',tal.transactionline) as transaction_line_id
    , tran.custbody_goodr_shopify_order order_id_edw
    , tran.tranid as transaction_id_ns
    , tal."ACCOUNT" as account_id_edw
    , tal."ACCOUNT" as account_id_ns
    , channel.name as channel
    , tran.trandate as transaction_timestamp
    , date(tran.trandate) as transaction_date
    , CONVERT_TIMEZONE('America/Los_Angeles', tran.trandate) AS transaction_timestamp_pst
    , date(CONVERT_TIMEZONE('America/Los_Angeles', tran.trandate)) as transaction_date_pst
    , CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) as date_posted_pst
    -- , case 
    --   when channel.name = 'Amazon' then tran.trandate
    --   else CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) 
    --   end as date_gl
    , case when tal.posting = 'T' then true else false end posting_flag
    , ap.periodname as posting_period
    , sum(coalesce(tal.amount,0)) as transaction_amount
    , sum(coalesce(tal.credit,0)) as  credit_amount
    , sum(coalesce(tal.debit,0)) as debit_amount
    , sum(coalesce(case 
      when ga.normal_balance = 'Debit' then (coalesce(tal.debit,0)) - (coalesce(tal.credit,0))
      when ga.normal_balance = 'Credit' then (coalesce(tal.credit,0)) - (coalesce(tal.debit,0))
      end,0)) as positive_amount
    , sum(coalesce(case 
      when ga.account_category in ('Assets','Expenses') then (coalesce(tal.debit,0)) - (coalesce(tal.credit,0))
      when ga.account_category in ('Liabilities','Equity','Revenue') then (coalesce(tal.credit,0)) - (coalesce(tal.debit,0))
      end,0)) as net_amount
    from
      netsuite.transactionaccountingline tal
    inner join
      netsuite.transaction tran
      on tal.transaction = tran.id
    inner join
      netsuite.accountingperiod ap
      on tran.postingperiod = ap.id
    left join
      dim.gl_account ga
      on tal."ACCOUNT" = ga.account_id_edw
    left join
      netsuite.transactionline tl
      on tran.id = tl.transaction
      and tal.transactionline = tl.id
    left join 
      netsuite.customrecord_cseg7 channel 
      on tl.cseg7 = channel.id
    left join
      netsuite.paymentevent pe
      on pe.doc = tran.id
    where
        date(tran.trandate) >= '2022-01-01' --limit the row count
    group by
     concat(tal.transaction,'_',tal.transactionline)
    , tran.custbody_goodr_shopify_order
    , tran.tranid
    , tal."ACCOUNT"
    , channel.name
    , tran.trandate
    , pe.eventdate
    , ap.periodname
    , case when tal.posting = 'T' then true else false end