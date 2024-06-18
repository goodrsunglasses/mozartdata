select
    date
  , round(sum(revenue), 2)     as revenue
  , round(sum(spend) , 2)      as spend
  , sum(impressions) as impressions
  , sum(clicks)      as clicks
  , round(sum(conversions), 2) as conversions
from
    fact.GOOGLE_ADS_CAMPAIGNS_DAILY_STATS
group by
    date
