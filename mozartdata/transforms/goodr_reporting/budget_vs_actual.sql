with
  budget as
  (
SELECT
  bl."ACCOUNT" as account_id_ns,
  ga.account_display_name,
  ga.account_number,
  category.name AS budget_version,
  cseg7.name as channel,
  bl.period,
  ap.periodname,
  SUM(amount) AS budget
FROM
  netsuite.budgetlegacy bl
  LEFT JOIN 
    draft_dim.gl_account ga 
  ON ga.account_id_ns = bl."ACCOUNT"
  LEFT JOIN 
    netsuite.budgetcategory category 
    ON category.id = bl.category
  LEFT JOIN 
    netsuite.customrecord_cseg7 cseg7 
    ON cseg7.id = bl.cseg7
  left join
    netsuite.accountingperiod ap
    on bl.period = ap.id
WHERE
  budget_version = '2023 - V3'
GROUP BY
  bl."ACCOUNT",
  ga.account_display_name,
  ga.account_number,
  category.name,
 cseg7.name,
  bl.period,
  ap.periodname
)
select
  b.account_display_name
  ,account_number
 -- , periodname
  , b.channel
  , budget
, sum(gt.amount_credit) as actual
  , sum(gt.amount_debit) as actual_debit
  , sum(gt.amount_net) as actual_net
from
  budget b
left join
  draft_fact.gl_transaction gt
  on b.account_id_ns = gt.account_id_ns
  and b.periodname = gt.posting_period
  and b.channel = gt.channel
  and gt.posting_flag = true
where
  b.account_number >= 4000 and b.account_number <5000
  --and periodname = 'Feb 2023'
group by
  b.account_id_ns
, b.account_display_name
, b.account_number
, b.budget_version
 , b.channel
--, b.period
--, b.periodname
 , b.budget
-- order by
--   b.period
-- , b.channel
/*

select * from draft_fact.gl_transaction gt where gt.account_id_ns = 269 and gt.posting_period = 'Jan 2023'
*/