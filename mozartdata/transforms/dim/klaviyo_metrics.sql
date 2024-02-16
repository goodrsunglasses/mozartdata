SELECT
  m.created as created_timestamp
, date(m.created) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', m.created) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', m.created)) as created_date_pst
, m.metric_id as metric_id_klaviyo
, m.name as name
FROM
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m
-- UNION ALL
-- SELECT
--   to_timestamp_ntz(km.created) as created_timestamp
-- , date(km.created) as created_date
-- , convert_timezone('UTC', 'America/Los_Angeles',to_timestamp_ntz(km.created)) as created_timestamp_pst
-- , date(convert_timezone('UTC', 'America/Los_Angeles', to_timestamp_ntz(km.created))) as created_date_pst
-- , km.id as metric_id_klaviyo
-- , km.name as name
-- FROM
--   klaviyo.metric km