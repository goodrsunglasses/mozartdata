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

  )
    select
      concat(pm.posting_period_year,' - Actual') as budget_version
    -- , ga.account_number
    -- , ga.account_id_edw
    , gt.posting_period
    , gt.transaction_date
    , dayofyear(gt.transaction_date) day_of_year
    , dayname(gt.transaction_date) day_of_week
    -- , date_trunc(week,gt.transaction_date) transaction_week
    -- , date_trunc(year,gt.transaction_date) transaction_year
    -- , week(gt.transaction_date) week_of_year
    , gt.channel
    -- , pm.posting_period_date
    -- , pm.posting_period_month
    -- , pm.posting_period_year
    , sum(gt.net_amount) as amount
    from
      fact.gl_transaction gt
    inner join
      dim.gl_account ga
      on ga.account_id_edw = gt.account_id_edw
    inner join
      period_map pm
      on gt.posting_period = pm.posting_period
      and pm.posting_period_year = '2024'
    where
      posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      concat(pm.posting_period_year,' - Actual')
    , gt.posting_period
    , gt.transaction_date
    , date_trunc(week,gt.transaction_date)
    , date_trunc(year,gt.transaction_date)
    , week(gt.transaction_date)
    , gt.channel
    , pm.posting_period_date
    , pm.posting_period_month
    , pm.posting_period_year
    order by
      transaction_date