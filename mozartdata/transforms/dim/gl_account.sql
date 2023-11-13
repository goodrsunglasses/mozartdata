/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per GL account.
This transform creates a GL account dimension that transforms Netsuites Account table into Goodr's EDW.

joins: 
self joins to account to pull the parent account number

aliases: 
acct = account
ns = netsuite
cust = customer
p = parent account
*/


select
  acct.id as account_id_edw
, acct.id as account_id_ns
, acct.acctnumber as account_number
, acct.fullname as account_full_name
, acct.accountsearchdisplaynamecopy as account_display_name
, acct.accountsearchdisplayname as account_number_display_name
, acct.displaynamewithhierarchy as account_number_display_name_hierarchy
, acct.description as account_description_ns --mostly NULL/missing. description in netsuite
, acct.parent as account_parent_id_netsuite
, p.acctnumber as account_parent_number
, p.accountsearchdisplayname as account_parent_number_display_name
, case
  when acct.accttype in ('AcctRec','Bank','DeferExpense','FixedAsset','OthAsset','OthCurrAsset') then 'Assets'
  when acct.accttype in ('AcctPay','CredCard','DeferRevenue','LongTermLiab','OthCurrLiab') then 'Liabilities'
  when acct.accttype in ('Equity') then 'Equity'
  when acct.accttype in ('Income','OthIncome') then 'Revenues'
  when acct.accttype in ('COGS','Expense','OthExpense') then 'Expenses'
  when acct.accttype in ('NonPosting') then 'Other'
  end as account_category
, case
  when account_number between 1600 and 1699 then 'Credit'
  when account_number in (1800, 1810, 1820) then 'Credit'
  when account_number between 4100 and 4299 then 'Debit'
  when account_number in (8002, 8020) then 'Debit'
  when account_category in ('Assets','Expenses') then 'Debit'
  when account_category in ('Liabilities','Equity','Revenues') then 'Credit'
  end as normal_balance
, acct.accttype as account_type
, acct.cashflowrate as cash_flow_rate
, acct.generalrate as general_rate
, case when acct.includechildren = 'T' then true else false end as include_children_flag
, case when acct.inventory = 'T' then true else false end as inventory_flag
, case when acct.isinactive = 'T' then false else true end as active_flag --the field in NS is called isINactive,I am flipping it to be active or not.
, case when acct.issummary = 'T' then true else false end as summary_flag 
, case when acct.reconcilewithmatching = 'T' then true else false end as reconcile_with_matching_flag
, case when acct.revalue = 'T' then true else false end as revalue_flag
from
  netsuite."ACCOUNT" acct
left join
  netsuite."ACCOUNT" p
  on acct.parent = p.id
where
  acct._fivetran_deleted = false
  and (p._fivetran_deleted = false or p._fivetran_deleted is null)
order by account_id_ns