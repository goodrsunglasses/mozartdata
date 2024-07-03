select
  date(crd.STAT_TIME_DAY) event_date
, crd.CAMPAIGN_ID as campaign_id_tiktok
, sum(crd.SPEND) as spend
, sum(crd.complete_payment*crd.value_per_complete_payment)as revenue
, sum(crd.IMPRESSIONS) as impressions
, sum(crd.CLICKS) as clicks
, sum(crd.CONVERSION) as conversions
from
  TIKTOK_ADS.CAMPAIGN_REPORT_DAILY crd
group by
  date(crd.STAT_TIME_DAY)
, crd.CAMPAIGN_ID
order by
  date(crd.STAT_TIME_DAY)