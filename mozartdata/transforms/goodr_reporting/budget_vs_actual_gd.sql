--- ACTUALS CTE from fact gl_transaction
with
  actual as
  (
    select
      ga.account_number
    , ga.account_id_ns
    , ga.account_full_name
    , concat(ga.account_number,' - ',ga.account_full_name) account_with_name
    , gt.posting_period
    , gt.channel
    , sum(gt.amount_transaction) amount_transaction
    , sum(gt.amount_net) amount_net
    , sum(gt.amount_credit) amount_credit
    , sum(gt.amount_debit) amount_debit
    , sum(gt.amount_transaction_positive) amount_transaction_positive
    from
      draft_fact.gl_transaction gt
    inner join
      draft_dim.gl_account ga
      on ga.account_id_ns = gt.account_id_ns
    where
---      gt.posting_period  in ('Jan 2023','Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023') and
      posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      ga.account_number
    , ga.account_id_ns
    , ga.account_full_name
    , concat(ga.account_number,' - ',ga.account_full_name)
    , gt.channel
    , gt.posting_period
  ),
  
--- BUDGET CTE from gl buget
  budget as
  (
  select
    *
  FROM
    draft_fact.gl_budget gb
  WHERE
    gb.budget_version in ('2023 - V3', '2023 - V2','2023 - V1')
  )

--- MAIN SELECT - UNIONED
SELECT posting_period, 'amount_credit' AS Type, amount_credit AS value
FROM actual

UNION ALL

SELECT posting_period, 'budget ' || budget_version AS Type, budget_amount AS value
FROM budget
ORDER BY posting_period, Type;

  /*
--- Main select
  SELECT
    a.*
  , b.budget_amount
  , b.budget_version
  FROM
    actual a
  left join
    budget b
    on a.account_id_ns = b.account_id_ns
    and a.channel = b.channel
    and a.posting_period = b.posting_period


/*
SELECT DISTINCT(budget_version) FROM draft_fact.gl_budget
SELECT * FROM draft_fact.gl_budget
*/