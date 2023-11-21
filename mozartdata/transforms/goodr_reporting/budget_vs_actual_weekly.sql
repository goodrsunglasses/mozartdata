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
    and posting_period_year = '2022'
  )
  ,new_year as
  (
    SELECT DISTINCT
      week_of_year
    , month
    , week_days_in_current_month
    , week_days_in_other_month
    FROM
      dim.date
    WHERE
      year = '2023'
  )
  
  
  , actuals as
  (
    select
      concat(pm.posting_period_year,' - Actual') as budget_version
    -- , ga.account_number
    -- , ga.account_id_edw
    , gt.posting_period
    , date_trunc(week,gt.transaction_date) transaction_week
    , date_trunc(year,gt.transaction_date) transaction_year
    , week(gt.transaction_date) week_of_year
    , gt.channel
    , pm.posting_period_date
    , pm.posting_period_month
    , pm.posting_period_year
    -- , sum(gt.credit_amount)-sum(gt.debit_amount) amount
    -- , sum(gt.debit_amount)
    -- , sum(gt.credit_amount)
    -- , ga.normal_balance
    , sum(gt.net_amount) amount
    -- , sum(gt.amount_debit) amount_debit
    -- , sum(gt.amount_transaction_positive) amount_transaction_positive
    from
      fact.gl_transaction gt
    inner join
      dim.gl_account ga
      on ga.account_id_edw = gt.account_id_edw
    inner join
      period_map pm
      on gt.posting_period = pm.posting_period
      and pm.posting_period_year >= '2021'
    where
     -- gt.posting_period  ='Jan 2023' --in ('Jan 2023','Feb 2023','Mar 2023','Apr 2023','May 2023','Jun 2023','Jul 2023','Aug 2023','Sep 2023')
      posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      concat(pm.posting_period_year,' - Actual')
    -- , ga.account_number
    -- , ga.account_id_edw
    , gt.posting_period
    , date_trunc(week,gt.transaction_date)
    , date_trunc(year,gt.transaction_date)
    , week(gt.transaction_date)
    , gt.channel
    , pm.posting_period_date
    , pm.posting_period_month
    , pm.posting_period_year
  )
  SELECT
    channel
  , transaction_year
  , transaction_week
  , a.week_of_year
  , posting_period
  , posting_period_month
  , amount
  -- , sum(amount) over (partition by channel, transaction_year, week_of_year, posting_period) x
  -- , sum(amount) over (partition by channel, posting_period) y
  , case when sum(amount) over (partition by channel, posting_period) = 0 then 0 else sum(amount) over (partition by channel, transaction_year, a.week_of_year, posting_period) / sum(amount) over (partition by channel, posting_period) end pct_of_posting_period
  , posting_period_date
  , CASE
    WHEN posting_period_month = MONTH(DATE_TRUNC('MONTH', transaction_week)) THEN 
      LEAST(DATEDIFF(DAY, transaction_week, LAST_DAY(transaction_week)),7)
    ELSE
      LEAST(7 - DATEDIFF(DAY, transaction_week, LAST_DAY(transaction_week)),7)
  END AS days_in_current_month_2022
  , case when days_in_current_month_2022 > 7 then 0 else 7 - days_in_current_month_2022 end as days_in_other_month_2022
  , ny.week_days_in_current_month as days_in_current_month_2023
  , ny.week_days_in_other_month as days_in_other_month_2023
  FROM
    actuals a
  LEFT JOIN
    new_year ny
    on a.week_of_year = ny.week_of_year
    and a.posting_period_month = ny.month
  where channel = 'Amazon'
  group by
      channel
  , transaction_year
  , transaction_week
  , a.week_of_year
  , posting_period
  , posting_period_month
  , amount
  , posting_period_date
  , ny.week_days_in_current_month
  , ny.week_days_in_other_month

  order by
    posting_period_date
  , transaction_year
  , week_of_year
  , channel