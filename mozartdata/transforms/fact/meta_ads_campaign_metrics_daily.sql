-- This SQL query is used to retrieve campaign performance data from Facebook Ads.
-- It joins multiple tables to gather data on impressions, inline link clicks, spend, conversions, and revenue.

-- Used downstream in the performance_media query

select
    mc.campaign_id_meta -- Unique identifier for the campaign in the meta database.
  , mc.campaign_name -- Name of the campaign.
  , mc.account_name -- Name of the Facebook Ads account.
  , cc.date -- Date of the campaign performance data.
  , cc.impressions -- Number of impressions for the campaign on the specified date.
  , coalesce(cc.inline_link_clicks, 0)                          as inline_link_clicks -- Number of inline link clicks for the campaign on the specified date.
  , cc.spend -- Amount spent on the campaign on the specified date.
  , coalesce(cca.value, 0)                                      as conversions -- Number of conversions (purchases) for the campaign on the specified date.
  , coalesce(ccav.value, fad."PURCHASES CONVERSION VALUE", 0)   as revenue -- Revenue generated from conversions (purchases) for the campaign on the specified date.
from
    dim.meta_campaigns                                          as mc
    left join
        facebook_ads.campaign_conversion                        as cc
            on
            mc.campaign_id_meta = cc.campaign_id
    left join
        facebook_ads.campaign_conversion_actions                as cca
            on
            cc.campaign_id = cca.campaign_id
                and cc.date = cca.date
                and cca.action_type = 'purchase'
    left join
        facebook_ads.campaign_conversion_action_values          as ccav
            on
            cc.campaign_id = ccav.campaign_id
                and cc.date = ccav.date
                and ccav.action_type = 'purchase'
    left join 
        upload_csvs.facebook_ads_data_20240101_20240806         as fad
            on
            cc.campaign_id = fad."CAMPAIGN ID"
                and cc.date = fad.day
where 
    cc.date is not null
    and cc.date >= '2024-01-01'
order by
    cc.date        asc -- Sort the results by date in descending order.
  , cc.campaign_id asc -- Sort the results by campaign ID in ascending order.