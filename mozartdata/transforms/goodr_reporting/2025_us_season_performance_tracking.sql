select
    social_channel as partner
  , TO_VARCHAR(DATE, 'Mon') as month
  , funnel_stage
  , sum(spend) as spend
  , sum(impressions) as impressions
  , sum(revenue) as purchase_value
  , sum(clicks) as clicks
  , sum(conversions) as purchases
from
  goodr_reporting.performance_media
where
  year = 2025
and account_country = 'USA'
and funnel_stage != 'OTHER'
group by all
