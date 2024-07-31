-- This SQL query retrieves data from Snapchat campaign metrics for
-- each campaign every day.

-- It joins the two tables based on the campaign ID and selects
-- relevant columns for analysis.

-- The results are ordered by campaign ID and report date in descending order.

select
    stats.campaign_id as campaign_id_snapchat,  -- Campaign ID from Snapchat
    cam.CAMPAIGN_NAME_SNAPCHAT,  -- Campaign name on Snapchat
    cam.marketing_strategy,  -- Campaign target audience
    cam.funnel_stage,  -- Campaign type
    cam.OBJECTIVE,  -- Campaign objective
    cam.START_DATE,  -- Campaign start date
    stats."DATE"::date as report_date,  -- Report date
    stats.impressions,  -- Number of impressions
    stats.swipes as clicks,  -- Number of clicks (swipes)
    round(stats.spend / 1000000, 2) as spend,  -- Total spend (converted from microcurrency)
    stats.CONVERSION_PURCHASES as conversions,  -- Number of conversions
    round(stats.CONVERSION_PURCHASES_VALUE / 1000000, 2) as revenue  -- Total revenue (converted from microcurrency)
from
    dim.SNAPCHAT_CAMPAIGNS as cam  -- Dimension table for Snapchat campaigns
inner join
    SNAPCHAT_ADS.CAMPAIGN_DAILY_REPORT as stats  -- Fact table for Snapchat campaign daily reports
    on
        cam.CAMPAIGN_ID_SNAPCHAT = stats.CAMPAIGN_ID  -- Join condition
order by
    stats.CAMPAIGN_ID,  -- Order by campaign ID
    stats."DATE"::date desc  -- Order by report date in descending order