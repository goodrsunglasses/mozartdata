/*
 Purpose: this table creates monthly balances for balance sheet accounts.
Transforms: In this query we combine all balance sheet accounts with all posting periods from december 2021 to present
 Balance sheet accounts are accounts 1000-3999

 */
--This CTE creates every combination of balance sheet account and posting periods beginning in December 2021
with account_periods as
  (
    select
      ap.posting_period
    , ap.period_start_date
    , ga_sub.account_number
    , ga_sub.account_id_edw
    from
      dim.accounting_period ap
    inner join
      (select
         ga.account_number
       , ga.account_id_edw
       from
         dim.gl_account ga
       where
         ga.account_number between 1000 and 3999
       and ga.active_flag = true) ga_sub
      on 1=1
    where
      ap.active_flag = true
      and ap.is_posting_flag = true
      and ap.period_start_date >= '2021-12-01'
  )
-- This CTE captures the starting balances from google_sheets.balance_dec_21 with all GL activity for balance sheet accounts
, gl_activity as
  (
SELECT
  h.posting_period
, h.posting_date
, h.account_number
, gt.account_id_ns
, gt.account_id_edw
, h.amount as balance
FROM google_sheets.balance_dec_21 h
left join fact.gl_transaction gt on gt.account_number = h.account_number
UNION
SELECT
 gt.posting_period
, to_date(gt.posting_period,'MON YYYY') posting_date
, gt.account_number
, gt.account_id_ns
, gt.account_id_edw
, sum(gt.net_amount) as balance
FROM
  fact.gl_transaction gt
WHERE
  gt.posting_flag = true
  and gt.account_number between 1000 and 3999
GROUP BY
  gt.posting_period
, to_date(gt.posting_period,'MON YYYY')
, gt.account_number
, gt.account_id_ns
, gt.account_id_edw
), all_activity as
(
select
  ap.posting_period
, ap.period_start_date
, ap.account_number
, ap.account_id_edw
, coalesce(ga.balance,0) as balance
from
  account_periods ap
left join
gl_activity ga
on ap.posting_period = ga.posting_period
  and ap.account_id_edw = ga.account_id_edw
)

select
  aa.posting_period
, aa.period_start_date
, aa.account_id_edw
, aa.account_number
, round(aa.balance,2) as current_period_amount
, sum(aa.balance) over (partition by aa.account_number order by aa.period_start_date) as ending_balance
FROM
  all_activity aa
order by
  aa.account_number
, aa.period_start_date
