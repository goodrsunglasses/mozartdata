-- This SQL query is used to retrieve campaign performance data from Facebook Ads.
-- It joins multiple tables to gather data on impressions, inline link clicks, spend, conversions, and revenue.

-- Used downstream in the performance_media query

select
    mc.campaign_id_meta -- Unique identifier for the campaign in the meta database.
  , mc.campaign_name -- Name of the campaign.
  , mc.account_name -- Name of the Facebook Ads account.
  , cc.date -- Date of the campaign performance data.
  , cc.impressions -- Number of impressions for the campaign on the specified date.
  , coalesce(cc.inline_link_clicks, 0) as inline_link_clicks -- Number of inline link clicks for the campaign on the specified date.
  , cc.spend -- Amount spent on the campaign on the specified date.
  , cca.value                          as conversions -- Number of conversions (purchases) for the campaign on the specified date.
  , ccav.value                         as revenue -- Revenue generated from conversions (purchases) for the campaign on the specified date.
from
    dim.meta_campaigns                                 as mc
    left join
        facebook_ads.campaign_conversion               as cc
            on
            mc.campaign_id_meta = cc.campaign_id
    left join
        facebook_ads.campaign_conversion_actions       as cca
            on
            cc.campaign_id = cca.campaign_id
                and cc.date = cca.date
    left join
        facebook_ads.campaign_conversion_action_values as ccav
            on
            cc.campaign_id = ccav.campaign_id
                and cc.date = ccav.date
where
      cca.action_type = 'purchase' -- Filter for conversions (purchases) only.
  and ccav.action_type = 'purchase' -- Filter for revenue generated from conversions (purchases) only.
order by
    cc.date        desc -- Sort the results by date in descending order.
  , cc.campaign_id asc -- Sort the results by campaign ID in ascending order.