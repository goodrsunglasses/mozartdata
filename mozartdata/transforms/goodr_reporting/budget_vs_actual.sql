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
    , sum(gt.credit_amount)-sum(gt.debit_amount) amount
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
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      concat(pm.posting_period_year,' - Actual')  
    , ga.account_number
    , ga.account_id_ns
    -- , ga.account_full_name
    -- , concat(ga.account_number,' - ',ga.account_full_name)
    , gt.channel
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
  , gb.budget_amount
  FROM
    fact.gl_budget gb
  inner join
    dim.gl_account ga
    on ga.account_id_edw = gb.account_id_edw
    and ga.account_number >= 4000 and ga.account_number < 5000
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
    bc.budget_version
  , bc.account_number
  , bc.account_id_ns
  , bc.channel
  , bc.amount
  , pm.posting_period
  , pm.posting_period_date
  , pm.posting_period_month
  , pm.posting_period_year
  , date(date_trunc(quarter, pm.posting_period_date)) as quarter_date,
  --, sum(bc2.amount)over (partition by bc2.budget_version, bc2.account_id_ns, bc.channel, pm.posting_period_date) ytd
  -- , sum(bc2.amount) ytd (3/4/2024 removed YTD)
  from
    ba_combined bc
  inner join
    period_map pm
    on pm.posting_period = bc.posting_period
  -- left join
  -- (
  --   select
  --     bc.budget_version
  --   , bc.account_number
  --   , bc.account_id_ns
  --   , bc.channel
  --   , bc.amount
  --   , pm.posting_period
  --   , pm.posting_period_date
  --   , pm.posting_period_month
  --   , pm.posting_period_year
  --   from
  --     ba_combined bc
  --   inner join
  --     period_map pm
  --     on pm.posting_period = bc.posting_period
  -- ) bc2
  --   on bc.budget_version = bc2.budget_version
  --   and bc.account_id_ns = bc2.account_id_ns
  --   and coalesce(bc.channel,'none') = coalesce(bc2.channel,'none')
  --   and pm.posting_period_year = bc2.posting_period_year
  --   and bc2.posting_period_date <= pm.posting_period_date
  -- group by
  --     bc.budget_version
  -- , bc.account_number
  -- , bc.account_id_ns
  -- , bc.channel
  -- , bc.amount
  -- , pm.posting_period
  -- , pm.posting_period_date
  -- , pm.posting_period_month
  -- , pm.posting_period_year
order by budget_version,account_number,channel,posting_period_date