select
    date
  , account_id_g_ads
  , account_name
  , case
        when campaign_name like '%BOF%'
            then 'Performance'
        when campaign_name like '%TOF%' or campaign_name like '%MOF%'
            then 'Awareness'
        else 'Other'
    end                        as funnel_stage
  , sum(revenue)     as revenue
  , sum(spend)       as spend
  , sum(impressions)           as impressions
  , sum(clicks)                as clicks
  , sum(conversions) as conversions
from
    fact.google_ads_campaigns_daily_stats
group by
    date
  , account_id_g_ads
  , account_name
  , funnel_stage