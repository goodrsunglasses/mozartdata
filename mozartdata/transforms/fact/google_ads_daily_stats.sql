select
    date
  , account_id_g_ads
  , account_name
  , case
        when campaign_name like '%BOF%'
            then 'Performance'
        when campaign_name like '%TOF%' or campaign_name like '%MOF%'
            then 'Awareness'
        else campaign_name
    end                        as funnel_stage
  , round(sum(revenue), 2)     as revenue
  , round(sum(spend), 2)       as spend
  , sum(impressions)           as impressions
  , sum(clicks)                as clicks
  , round(sum(conversions), 2) as conversions
from
    fact.google_ads_campaigns_daily_stats
group by
    date
  , account_id_g_ads
  , account_name
  , funnel_stage