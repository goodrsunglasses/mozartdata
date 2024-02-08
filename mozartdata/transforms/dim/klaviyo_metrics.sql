SELECT
  m.created as metric_created_timestamp
, date(m.created) as metric_created_date
, m.metric_id as metric_id_klaviyo
, m.name as name
FROM
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m
UNION ALL
SELECT
  to_timestamp_ntz(km.created) as metric_created_timestamp
, date(km.created) as metric_created_date
, km.id as metric_id_klaviyo
, km.name as name
FROM
  klaviyo.metric km