with
  period_map as
  (
    select distinct
      ap.periodname as posting_period
    , try_to_date(posting_period,'Mon YYYY') posting_period_date
    , MONTH(TO_DATE(posting_period,'Mon YYYY')) posting_period_month
    , YEAR(TO_DATE(posting_period,'Mon YYYY')) posting_period_year
    from
      netsuite.accountingperiod ap
    WHERE
      try_to_date(posting_period,'Mon YYYY') is not null

  ),
  actual as
  (
    select
      concat(pm.posting_period_year,' - Actual') as budget_version
    , ga.account_number
    , ga.account_id_ns
    , gt.posting_period
    , gt.channel
    , gt.department
    , gt.department_id_ns
    , sum(gt.net_amount) amount
    -- , sum(gt.amount_debit) amount_debit
    -- , sum(gt.amount_transaction_positive) amount_transaction_positive
    from
      fact.gl_transaction gt
    inner join
      dim.gl_account ga
      on ga.account_id_ns = gt.account_id_ns
    inner join
      period_map pm
      on gt.posting_period = pm.posting_period
      and pm.posting_period_year >= '2021'
    where
      --gt.posting_period  in ('Jan 2023','Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023')
      posting_flag = true
    and ga.account_number >= 6000 and ga.account_number < 9000
    group by
      concat(pm.posting_period_year,' - Actual')  
    , ga.account_number
    , ga.account_id_ns
    , gt.channel
    , gt.department
    , gt.department_id_ns
    , gt.posting_period
  ),
  budget as
  (
  select
    gb.budget_version
  , ga.account_number
  , gb.account_id_edw
  , gb.posting_period
  , gb.channel
  , gb.department
  , gb.department_id_ns
  , gb.budget_amount
  FROM
    fact.gl_budget gb
  inner join
    dim.gl_account ga
    on ga.account_id_edw = gb.account_id_edw
    and ga.account_number >= 6000 and ga.account_number < 9000
  ),
  ba_combined as 
  (
  SELECT
    *
  FROM
    actual a
  union
  SELECT
    *
  FROM
    budget b
  )
  select
    bc.*
  , pm.posting_period_date
  , pm.posting_period_month
  , pm.posting_period_year
  from
    ba_combined bc
  inner join
    period_map pm
    on pm.posting_period = bc.posting_period
  where bc.posting_period like '%24'