-- This SQL query retrieves data from Snapchat campaign metrics for
-- each campaign every day.

-- It joins the two tables based on the campaign ID and selects
-- relevant columns for analysis.

-- The results are ordered by campaign ID and report date in descending order.

-- used downstream in the performance_media table

select
    stats.campaign_id                                    as campaign_id_snapchat -- Campaign ID from Snapchat
  , cam.campaign_name_snapchat -- Campaign name on Snapchat
  , cam.marketing_strategy -- Campaign target audience
  , cam.funnel_stage -- Campaign type
  , cam.objective -- Campaign objective
  , cam.start_date -- Campaign start date
  , stats."DATE"::date                                   as report_date -- Report date
  , stats.impressions -- Number of impressions
  , stats.swipes                                         as clicks -- Number of clicks (swipes)
  , stats.spend / 1000000                                as spend -- Total spend (converted from microcurrency)
  , stats.conversion_purchases                           as conversions -- Number of conversions
  , stats.conversion_purchases_value / 1000000           as revenue -- Total revenue (converted from microcurrency)
from
    dim.snapchat_campaigns                 as cam -- Dimension table for Snapchat campaigns
    inner join
        snapchat_ads.campaign_daily_report as stats -- Fact table for Snapchat campaign daily reports
            on
            cam.campaign_id_snapchat = stats.campaign_id -- Join condition
order by
    stats.campaign_id -- Order by campaign ID
  , stats."DATE"::date desc -- Order by report date in descending order