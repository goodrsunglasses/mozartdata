select distinct
  ch.CAMPAIGN_ID as campaign_id_tiktok
, ch.CAMPAIGN_NAME
, case
  when ch.CAMPAIGN_NAME like '%TOF%' then 'TOF'
  when ch.CAMPAIGN_NAME like '%MOF%' then 'MOF'
  when ch.CAMPAIGN_NAME like '%BOF%' then 'BOF'
  else 'OTHER'
  end as funnel_stage
, case
  when ch.CAMPAIGN_NAME like '%TOF%' then 'Reach'
  when ch.CAMPAIGN_NAME like '%MOF%' then 'Traffic, Engagement'
  when ch.CAMPAIGN_NAME like '%BOF%' then 'Sales, Conversions'
  else 'Other'
  end as campaign_strategy
, case
  when ch.CAMPAIGN_NAME like '%TOF%' then 'Awareness'
  when ch.CAMPAIGN_NAME like '%MOF%' then 'Awareness'
  when ch.CAMPAIGN_NAME like '%BOF%' then 'Performance'
  else 'Other'
  end as media_strategy
, ch.CAMPAIGN_TYPE
, ch.BUDGET_MODE
, ch.OPERATION_STATUS
, ch.OBJECTIVE_TYPE
, ch.CREATE_TIME
, date(ch.CREATE_TIME) create_date
from
  TIKTOK_ADS.CAMPAIGN_HISTORY ch
order by
  ch.CAMPAIGN_ID