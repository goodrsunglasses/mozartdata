select
    date
  , case
        when name like '%BOF%'
            then 'Performance'
        when name like '%TOF%' or name like '%MOF%'
            then 'Awareness'
        else name
    end                        as funnel_stage
  , round(sum(revenue), 2)     as revenue
  , round(sum(spend), 2)       as spend
  , sum(impressions)           as impressions
  , sum(clicks)                as clicks
  , round(sum(conversions), 2) as conversions
from
    fact.GOOGLE_ADS_CAMPAIGNS_DAILY_STATS
group by
    date
  , funnel_stage
