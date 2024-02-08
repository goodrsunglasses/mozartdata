SELECT
  m.created as metric_created_timestamp
, date(m.created) as metric_created_date
, m.metric_id as metric_id_klayvio
, m.name as name
FROM
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m