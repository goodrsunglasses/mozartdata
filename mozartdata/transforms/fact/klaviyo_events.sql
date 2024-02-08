SELECT
  e.datetime as event_timestamp
, date(e.datetime) as event_date
, e.metric_id as metric_id_klaviyo
FROM
  klaviyo_portable.klaviyo_v2_events_8589937320 e