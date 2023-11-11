with
  period as
  (
    select distinct
      d.posting_period
    , d.date
    , d.year  
    , d.month
    , d.day
    , d.date_int
    from
      dim.date d
    WHERE
      d.day = 1
    and d.year between 2022 and 2023
  ),
  channels as
  (
    select distinct
      channel
    from
      fact.gl_budget gb
    where
      channel is not null
  ),
  period_map as
  (
    select
      *
    from
      channels
    inner join
      period
    on 1=1 
  ),
  actual as
  (
    select
      concat(pm.year,' - Actual') as budget_version
    , pm.date_int
    , pm.posting_period
    , pm.channel
    , coalesce(gt.amount,0) amount
    from
      period_map pm
    left join
      (
      select
        gt.channel
      , gt.posting_period
      , sum(gt.credit_amount)-sum(gt.debit_amount) as amount
      from
        fact.gl_transaction gt
      inner join
        draft_dim.gl_account ga
        on ga.account_id_ns = gt.account_id_ns
      where
        posting_flag = true
        and ga.account_number >= 4000 and ga.account_number < 5000
      group by
          gt.channel
        , gt.posting_period
      ) gt
        on gt.posting_period = pm.posting_period
        and gt.channel = pm.channel
  ),
  mom as
  (
SELECT
  a.budget_version
, a.date_int
, a.posting_period
, a.channel
, a.amount
, lag(a.amount) over (partition by a.channel order by a.date_int) as previous_amount
, case when lag(a.amount) over (partition by a.channel order by a.date_int) = 0 then 0 else (a.amount/lag(a.amount) over (partition by a.channel order by a.date_int))  end mom_growth
FROM
  actual a
where
  a.channel = 'Goodr.com'
order by
  channel
  , date_int asc
  )
select
  *
  , AVG(mom_growth) OVER (partition by m.channel ORDER BY m.date_int ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_mom_average
  , AVG(mom_growth) OVER (partition by m.channel ORDER BY m.date_int ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS rolling_3_month_mom_average_ex
  , m.previous_amount * AVG(mom_growth) OVER (partition by m.channel ORDER BY m.date_int ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as projected_amount
  , m.previous_amount * AVG(mom_growth) OVER (partition by m.channel ORDER BY m.date_int ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) as projected_amount_ex
from
  mom m