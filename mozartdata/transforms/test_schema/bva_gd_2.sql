--- 2023 ACTUAL
with
  actual as
  (
    select
      '2023 - Actual' as budget_version
    , ga.account_number
    , ga.account_id_ns
    , gt.posting_period
    , gt.channel
    , sum(gt.credit_amount)-sum(gt.debit_amount) amount
    -- , sum(gt.amount_debit) amount_debit
    -- , sum(gt.amount_transaction_positive) amount_transaction_positive
    from
      draft_fact.gl_transaction gt
    inner join
      draft_dim.gl_account ga
      on ga.account_id_ns = gt.account_id_ns
    where
      gt.posting_period  in ('Jan 2023','Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023')
      and posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      ga.account_number
    , ga.account_id_ns
    -- , ga.account_full_name
    -- , concat(ga.account_number,' - ',ga.account_full_name)
    , gt.channel
    , gt.posting_period
  ),
--- 2022 ACUTAL
  actual_2022 as
  (
    select
      '2022 - Actual' as budget_version
    , ga.account_number
    , ga.account_id_ns
    , gt.posting_period
    , gt.channel
    , sum(gt.credit_amount)-sum(gt.debit_amount) amount
    -- , sum(gt.amount_debit) amount_debit
    -- , sum(gt.amount_transaction_positive) amount_transaction_positive
    from
      draft_fact.gl_transaction gt
    inner join
      draft_dim.gl_account ga
      on ga.account_id_ns = gt.account_id_ns
    where
      gt.posting_period  in ('Jan 2022','Feb 2022','Mar 2022','Apr 2022','May 2022','Jun 2022','Jul 2022','Aug 2022','Sep 2022')
      and posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      ga.account_number
    , ga.account_id_ns
    -- , ga.account_full_name
    -- , concat(ga.account_number,' - ',ga.account_full_name)
    , gt.channel
    , gt.posting_period
  ),

--- BUDGET 
  budget as
  (
  select
    gb.budget_version
  , ga.account_number
  , gb.account_id_ns
  , gb.posting_period
  , gb.channel
  , gb.budget_amount
  FROM
    draft_fact.gl_budget gb
  inner join
    draft_dim.gl_account ga
    on ga.account_id_ns = gb.account_id_ns
    and ga.account_number >= 4000 and ga.account_number < 5000
  )
  SELECT
    *
  FROM
    actual a
  union
  SELECT
    *
  FROM
    budget b
  UNION
  SELECT 
*
from actual_2022 a22