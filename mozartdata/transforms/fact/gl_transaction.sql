/*
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
    , pt.order_id_edw
    , COALESCE(pt.order_id_ns,REPLACE(COALESCE(tran.custbody_goodr_shopify_order,tran.custbody_goodr_po_number),' ','')) as order_id_ns
    , tran.id as transaction_id_ns
    , tran.tranid as transaction_number_ns
    , tran.recordtype as record_type --helpful for QC
    , tal."ACCOUNT" as account_id_edw
    , tal."ACCOUNT" as account_id_ns
    , tal.transactionline as transaction_line_id_ns
    , ga.account_number
    , ga.budget_category
    , channel.name as channel
    , tran.trandate as transaction_timestamp
    , date(tran.trandate) as transaction_date
    , CONVERT_TIMEZONE('America/Los_Angeles', tran.trandate) AS transaction_timestamp_pst
    , date(CONVERT_TIMEZONE('America/Los_Angeles', tran.trandate)) as transaction_date_pst
    , CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', pe.eventdate::timestamp_ntz) as date_posted_pst
    , case when tal.posting = 'T' then true else false end posting_flag
    , ap.posting_period as posting_period
    , sum(coalesce(tal.amount,0)) as transaction_amount
    , sum(coalesce(tal.credit,0)) as  credit_amount
    , sum(coalesce(tal.debit,0)) as debit_amount
    , sum(coalesce(case 
      when ga.normal_balance = 'Debit' then (coalesce(tal.debit,0)) - (coalesce(tal.credit,0))
      when ga.normal_balance = 'Credit' then (coalesce(tal.credit,0)) - (coalesce(tal.debit,0))
      end,0)) as normal_balance_amount
    , sum(coalesce(case 
      when ga.account_category in ('Assets','Expenses') then (coalesce(tal.debit,0)) - (coalesce(tal.credit,0))
      when ga.account_category in ('Liabilities','Equity','Revenues') then (coalesce(tal.credit,0)) - (coalesce(tal.debit,0))
      end,0)) as net_amount
    , tl.createdfrom as parent_transaction_id_ns
    , tl.item as item_id_ns
    , p.product_id_edw
    , tran.entity as customer_id_ns
    , cnm.customer_id_edw
    , cnm.tier
    , tl.department as department_id_ns
    , d.name as department
    , tran.memo as memo
    , tl.memo as line_memo
    , e.altname as line_entity   
    , e.type as line_entity_type  
    , c.fullname as line_class
    , case when tl.cleared = 'T' then true else false end as cleared_flag
    , date(tl.cleareddate) AS cleared_date
    , tran.custbody_boomi_orderid as order_id_shopify
    from
      netsuite.transactionaccountingline tal
    inner join
      netsuite.transaction tran
      on tal.transaction = tran.id
    inner join
      dim.accounting_period ap
      on tran.postingperiod = ap.accounting_period_id
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
    left join
      netsuite.department d
      on tl.department = d.id
    left join
      dim.parent_transactions pt
      on tran.id = pt.transaction_id_ns
    left join
      fact.customer_ns_map cnm
      on tran.entity = cnm.customer_id_ns
    left join
      netsuite.classification c
      on c.id = tl.class
    left join
      dim.product p
      on p.item_id_ns = tl.item
  left join     
      netsuite.entity e 
      on tl.entity = e.id
    where
        date(tran.trandate) >= '2022-01-01' --limit the row count
    and (tran._fivetran_deleted = false or tran._fivetran_deleted is null)
    and (tal._fivetran_deleted = false or tal._fivetran_deleted is null)
    and (tl._fivetran_deleted = false or tl._fivetran_deleted is null)
    and (pe._fivetran_deleted = false or pe._fivetran_deleted is null)
    group by
     concat(tal.transaction,'_',tal.transactionline)
    , pt.order_id_edw
    , COALESCE(pt.order_id_ns,REPLACE(COALESCE(tran.custbody_goodr_shopify_order,tran.custbody_goodr_po_number),' ',''))
    , tran.id
    , tran.tranid
    , tran.recordtype
    , tal."ACCOUNT"
    , tal.transactionline
    , ga.account_number
    , ga.budget_category
    , channel.name
    , tran.trandate
    , pe.eventdate
    , ap.posting_period
    , case when tal.posting = 'T' then true else false end
    , createdfrom
    , tran.entity
    , cnm.customer_id_edw
    , cnm.tier
    , tl.department
    , tl.item
    , p.product_id_edw
    , d.name
    , tran.memo
    , tl.memo
    , c.fullname
    , tl.cleared
    , tl.cleareddate
    , tran.custbody_boomi_orderid
    , e.altname   
    , e.type