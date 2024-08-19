select
    mc.campaign_id_meta
  , mc.campaign_name
  , mc.account_name
  , cc.date                            as date
  , cc.impressions                     as impressions
  , coalesce(cc.inline_link_clicks, 0) as inline_link_clicks
  , cc.spend                           as spend
  , cca.value                          as conversions
  , ccav.value                         as revenue
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
      cca.action_type = 'purchase'
  and ccav.action_type = 'purchase'
order by
    cc.date        desc
  , cc.campaign_id asc