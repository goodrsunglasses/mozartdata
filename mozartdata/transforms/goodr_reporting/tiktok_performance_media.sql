with weeks as
  (
    select distinct
      d.date
    , d.sales_season
    , d.week_start_date as period_start
    , dateadd(day, 13, d.week_start_date) as period_end
    , d.week_start_date
    , d.week_end_date
    , d.week_of_year
    , CEIL(week_of_year / 2.0) AS week_group
    , d.week_year as year_of_week
    from
      dim.date d
     where
       d.week_year = '2024'
  ), week_periods as
  (
   select distinct
      d.week_of_year
    , d.week_start_date as period_start
    , dateadd(day, 13, d.week_start_date) as period_end
    , CEIL(d.week_of_year / 2.0) AS week_group
    , YEAROFWEEK(date) as year_of_week
   from
      dim.date d
     where
       YEAROFWEEK(date) = '2024'
     order by d.week_of_year
  ), grid AS
  (
    select distinct
      w.date
    , w.week_of_year
    , w.year_of_week
    , min(wp.period_start) over (partition by w.week_of_year) period_start
    , min(wp.period_end) over (partition by w.week_of_year) period_end
    , w.week_start_date
    , w.week_end_date
    , CONCAT('Week ', w.week_group * 2 - 1, '/', w.week_group * 2) AS week_label
    , w.sales_season
    from
      weeks w
    left join
      week_periods wp
      on w.week_group = wp.week_group
    order by
      w.year_of_week
    , w.week_of_year
  )select * from grid;
select
  g.date
, g.week_of_year
, g.period_start
, g.period_end
, g.week_start_date
, g.week_end_date
, g.week_label
, tmd.event_date
, case when tc.funnel_stage in ('TOF','MOF') then 'TOF/MOF' else tc.funnel_stage end as funnel_stage
, sum(tmd.SPEND) as spend
, sum(tmd.REVENUE)as revenue
, sum(tmd.IMPRESSIONS) as impressions
, sum(tmd.CLICKS) as clicks
, sum(tmd.CONVERSIONS) as conversions
from
  fact.tiktok_campaign_metrics_daily tmd
inner join
  dim.tiktok_campaigns tc
  on tmd.campaign_id_tiktok = tc.campaign_id_tiktok
left join
  grid g
  on tmd.event_date = g.date
group by
  g.date
, g.week_of_year
, g.period_start
, g.period_end
, g.week_start_date
, g.week_end_date
, g.week_label
, g.sales_season
, tmd.event_date
, case when tc.funnel_stage in ('TOF','MOF') then 'TOF/MOF' else tc.funnel_stage end
order by
  g.date
, funnel_stage