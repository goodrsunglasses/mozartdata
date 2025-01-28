with
  period_map as
  (
    select distinct
      ap.periodname as posting_period
    , try_to_date(posting_period,'Mon YYYY') posting_period_date
    , MONTH(TO_DATE(posting_period,'Mon YYYY')) posting_period_month
    , YEAR(TO_DATE(posting_period,'Mon YYYY')) posting_period_year
    , date_from_parts(YEAR(TO_DATE(posting_period,'Mon YYYY')), 1, 1) ytd_start_date
  
    from
      netsuite.accountingperiod ap
    WHERE
      try_to_date(posting_period,'Mon YYYY') is not null
  ),
  actual as
  (
    select
      concat(pm.posting_period_year,' - Actual') as budget_version
--    , ga.account_number
--    , ga.account_id_ns
    , gt.posting_period
    , gt.channel
    , sum(net_amount) as amount
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
      posting_flag = true
    and ga.account_number >= 4000 and ga.account_number < 5000
    group by
      concat(pm.posting_period_year,' - Actual')  
--    , ga.account_number
--    , ga.account_id_ns
    , gt.channel
    , gt.posting_period
  ),
  budget as
  (
    select
      gb.budget_version
--    , ga.account_number
--    , gb.account_id_edw
    , gb.posting_period
    , gb.channel
    , sum(gb.budget_amount) as budget_amount
    from
      fact.gl_budget gb
    inner join
      dim.gl_account ga
      on ga.account_id_edw = gb.account_id_edw
      and ga.account_number >= 4000 and ga.account_number < 5000
  group by all
  ),
  ba_combined as 
  (
    select * from actual a
    union
    select * from budget b
  )
select
  bc.budget_version
--, bc.account_number
--, bc.account_id_ns
, bc.channel
, bc.amount
, pm.posting_period
, pm.posting_period_date
, pm.posting_period_month
, pm.posting_period_year
, date(date_trunc(quarter, pm.posting_period_date)) as quarter_date
, sum(bc.amount) over (
    partition by bc.budget_version, bc.channel, pm.posting_period_year
    order by pm.posting_period_date
  ) as ytd_total -- YTD calculation
, sum(bc.amount) over (
    partition by bc.budget_version, bc.channel, (date(date_trunc(quarter, pm.posting_period_date)))
    order by pm.posting_period_date
  ) as qtd_total -- QTD calculation
from
  ba_combined bc
inner join
  period_map pm
  on pm.posting_period = bc.posting_period
order by budget_version, channel, posting_period_date;