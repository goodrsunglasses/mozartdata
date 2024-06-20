select distinct
  ch.id as campaign_id_meta
, ch.name as campaign_name
, case
  when ch.name like '%TOF%' then 'TOF'
  when ch.name like '%MOF%' then 'MOF'
  when ch.name like '%BOF%' then 'BOF'
  else 'OTHER'
  end as funnel_stage
, case
  when ch.name like '%TOF%' then 'Reach'
  when ch.name like '%MOF%' then 'Traffic, Engagement'
  when ch.name like '%BOF%' then 'Sales, Conversions'
  else 'Other'
  end as campaign_strategy
, case
  when ch.name like '%TOF%' then 'Awareness'
  when ch.name like '%MOF%' then 'Awareness'
  when ch.name like '%BOF%' then 'Performance'
  else 'Other'
  end as media_strategy
, ch.source_campaign_id as parent_campaign_id_meta
, ch.configured_status
, ch.effective_status
, ch.bid_strategy
, ch.buying_type
, ch.can_use_spend_cap
, ch.daily_budget
, ch.lifetime_budget
, ch.objective
, ch.smart_promotion_type
, ch.created_time
, date(ch.created_time) as created_date
, ch.start_time
, date(ch.start_time) as start_date
, ch.stop_time
, date(ch.stop_time) as stop_date
from
  facebook_ads.CAMPAIGN_HISTORY ch
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_time DESC) = 1

