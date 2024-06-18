with
    tiktok as
    (
select
  tmd.event_date
, 'tiktok' as social_channel
, case when tc.funnel_stage in ('TOF','MOF') then 'TOF/MOF' else tc.funnel_stage end as funnel_stage
, case
  when tc.funnel_stage in ('TOF','MOF') then 'Awareness'
  when tc.funnel_stage in ('BOF') then 'Performance'
  else 'Other' end as marketing_strategy
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
where
  tc.funnel_stage in ('TOF','MOF','BOF')
group by
  tmd.event_date
, tc.funnel_stage
    )
select
  d.date
, d.week_of_year
, d.media_period_start_date
, d.media_period_end_date
, d.media_week_label
, t.social_channel
, t.funnel_stage
, t.marketing_strategy
, sum(t.clicks) as clicks
, sum(t.conversions) as conversions
, sum(t.impressions) as impressions
, sum(t.revenue) as revenue
, sum(t.spend) as spend
from
    dim.date d
left join
    tiktok t
    on t.event_date = d.date
where
    d.week_year >= 2024
group by
    d.date
, d.week_of_year
, d.media_period_start_date
, d.media_period_end_date
, d.media_week_label
, t.social_channel
, t.funnel_stage
, t.marketing_strategy