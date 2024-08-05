-- This SQL script generates a grid-like structure based on date and week-related information.

-- It also joins with SNAPCHAT_CAMPAIGN_DAILY_METRICS and SNAPCHAT_CAMPAIGNS tables to retrieve
-- campaign-related metrics.

-- The query filters the data based on the funnel stages and groups the results by various
-- dimensions.

-- CTE: weeks
-- Selects distinct date, sales season, and week-related information from dim.date table
-- for the year 2024.
with weeks as (
    select distinct
        d.date
      , d.sales_season
      , d.week_start_date                   as period_start
      , dateadd(day, 13, d.week_start_date) as period_end
      , d.week_start_date
      , d.week_end_date
      , d.week_of_year
      , CEIL(week_of_year / 2.0)            AS week_group
      , d.week_year                         as year_of_week
    from
        dim.date d
    where
        d.week_year = '2024'
)
-- CTE: week_periods
-- Selects distinct week-related information from dim.date table for the year 2024.
-- It also calculates the period start and end dates based on the week group.
, week_periods as (
    select distinct
        d.week_of_year
      , d.week_start_date                   as period_start
      , dateadd(day, 13, d.week_start_date) as period_end
      , CEIL(d.week_of_year / 2.0)          AS week_group
      , YEAROFWEEK(date)                    as year_of_week
    from
        dim.date d
    where
        YEAROFWEEK(date) = '2024'
    order by
        d.week_of_year
)
-- CTE: grid
-- Generates a grid-like structure by joining weeks and week_periods CTEs.
-- It also calculates the week label and sales season.
, grid AS (
    select distinct
        w.date
      , w.week_of_year
      , w.year_of_week
      , min(wp.period_start) over (partition by w.week_of_year)        as period_start
      , min(wp.period_end) over (partition by w.week_of_year)          as period_end
      , w.week_start_date
      , w.week_end_date
      , CONCAT('Week ', w.week_group * 2 - 1, ' / ', w.week_group * 2) AS week_label
      , w.sales_season
    from
        weeks            w
        left join
            week_periods wp
                on w.week_group = wp.week_group
    order by
        w.year_of_week
      , w.week_of_year
)

-- Main query
-- Selects required columns from grid, SNAPCHAT_CAMPAIGN_DAILY_METRICS,
-- and SNAPCHAT_CAMPAIGNS tables.
-- It also performs calculations on the metrics and filters the data based on funnel stages.
select
  g.date
, g.week_of_year
, g.period_start
, g.period_end
, g.week_start_date
, g.week_end_date
, g.week_label
, case
    when snap_cams.funnel_stage in ('TOF','MOF')
        then 'TOF/MOF'
    else snap_cams.funnel_stage
end as funnel_stage
, snap_cams.marketing_strategy
, g.sales_season
, sum(snap_daily.SPEND) as spend
, sum(snap_daily.REVENUE)as revenue
, sum(snap_daily.IMPRESSIONS) as impressions
, sum(snap_daily.CLICKS) as clicks
, sum(snap_daily.CONVERSIONS) as conversions
from
  fact.snapchat_campaign_metrics_daily as snap_daily
inner join
  dim.SNAPCHAT_CAMPAIGNS as snap_cams
  on snap_daily.campaign_id_snapchat = snap_cams.campaign_id_snapchat
left join
  grid g
  on snap_daily.REPORT_DATE = g.date
where
  snap_cams.funnel_stage in ('TOF','MOF','BOF')
group by
  g.date
, g.week_of_year
, g.period_start
, g.period_end
, g.week_start_date
, g.week_end_date
, g.week_label
, g.sales_season
, snap_cams.funnel_stage
, snap_cams.marketing_strategy
order by
  g.date
, snap_cams.funnel_stage