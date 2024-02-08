SELECT
  e.datetime as event_timestamp
, date(e.datetime) as event_date
, e.metric_id as metric_id_klaviyo
, e.profile_id as profile_id_klaviyo
, m.name as metric_name
FROM
  klaviyo_portable.klaviyo_v2_events_8589937320 e
LEFT JOIN
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m
  on e.metric_id = m.metric_id
UNION ALL
SELECT
  to_timestamp_ntz(ke.datetime) as event_timestamp
, date(ke.datetime) as event_date
, ke.metric_id as metric_id_klaviyo
, ke.person_id as profile_id_klaviyo
, km.name as metric_name
FROM
  klaviyo.event ke
LEFT JOIN
  klaviyo.metric km
  on ke.metric_id = km.id