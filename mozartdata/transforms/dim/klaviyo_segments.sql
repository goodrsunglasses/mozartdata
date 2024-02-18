SELECT
  s.created as created_timestamp
, date(s.created) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.created) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.created)) as created_date_pst
, s.segment_id as segment_id_klaviyo
, s.name
, s.updated as updated_timestamp
, date(s.updated) as updated_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.updated) as updated_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.updated)) as updated_date_pst
FROM
  klaviyo_portable.klaviyo_v2_segments_8589937320 s
-- union
-- SELECT
--   to_timestamp_ntz(ks.created) as segement_created_timestamp
-- , date(ks.created) as segement_created_date
-- , ks.id as segment_id_klaviyo
-- , ks.name
-- FROM
--   klaviyo.segment ks