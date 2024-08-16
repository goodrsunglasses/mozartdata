with
    tiktok as
        (
            select
                tmd.event_date
              , 'tiktok'             as social_channel
              , case
                    when tc.funnel_stage in ('TOF', 'MOF')
                        then 'Awareness'
                    when tc.funnel_stage in ('BOF')
                        then 'Performance'
                    else 'Other'
                end                  as marketing_strategy
              , sum(tmd.spend)       as spend
              , sum(tmd.revenue)     as revenue
              , sum(tmd.impressions) as impressions
              , sum(tmd.clicks)      as clicks
              , sum(tmd.conversions) as conversions
            from
                fact.tiktok_campaign_metrics_daily tmd
                inner join
                    dim.tiktok_campaigns           tc
                        on tmd.campaign_id_tiktok = tc.campaign_id_tiktok
            where
                tc.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                tmd.event_date
              , tc.funnel_stage
        )
  , g_ads as
        (
            select
                ga.date      as event_date
              , 'google ads' as social_channel
              , case
                    when ga.funnel_stage not in ('Awareness', 'Performance')
                        then 'Other'
                    else ga.funnel_stage
                end          as marketing_strategy
              , ga.spend
              , ga.revenue
              , ga.impressions
              , ga.clicks
              , ga.conversions
            from
                fact.google_ads_daily_stats ga
        )
  , snap_ads as (
            select
                scmd.report_date            as event_date
              , 'snapchat'                  as social_channel
              , scmd.marketing_strategy
              , round(sum(scmd.spend), 2)   as spend
              , round(sum(scmd.revenue), 2) as revenue
              , sum(scmd.impressions)       as impressions
              , sum(scmd.clicks)            as clicks
              , sum(scmd.conversions)       as conversions
            from
                fact.snapchat_campaign_metrics_daily scmd
            where
                scmd.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                scmd.report_date
              , scmd.marketing_strategy
        )
  , meta_ads as (
            select
                macmd.date                    as event_date
              , 'meta'                        as social_channel
              , mc.media_strategy             as marketing_strategy
              , round(sum(macmd.spend), 2)    as spend
              , round(sum(macmd.revenue), 2)  as revenue
              , sum(macmd.impressions)        as impressions
              , sum(macmd.inline_link_clicks) as clicks
              , sum(macmd.conversions)        as conversions
            from
                dim.meta_campaigns                       mc
                inner join
                    fact.meta_ads_campaign_metrics_daily macmd
                        on mc.campaign_id_meta = macmd.campaign_id_meta
            where
                mc.funnel_stage in ('TOF', 'MOF', 'BOF')
            group by
                macmd.date
              , mc.media_strategy
        )
  , combined as
        (
            select
                *
            from
                tiktok
            union all
            select
                *
            from
                g_ads
            union all
            select
                *
            from
                snap_ads
            union all
            select
                *
            from
                meta_ads
        )
select
    d.date
  , d.week_of_year
  , d.media_period_start_date
  , d.media_period_end_date
  , d.media_week_label
  , c.social_channel
  , c.marketing_strategy
  , sum(c.clicks)      as clicks
  , sum(c.conversions) as conversions
  , sum(c.impressions) as impressions
  , sum(c.revenue)     as revenue
  , sum(c.spend)       as spend
from
    dim.date     d
    left join
        combined c
            on c.event_date = d.date
where
      d.week_year >= 2024
  and d.date <= current_date()
group by
    d.date
  , d.week_of_year
  , d.media_period_start_date
  , d.media_period_end_date
  , d.media_week_label
  , c.social_channel
  , c.marketing_strategy