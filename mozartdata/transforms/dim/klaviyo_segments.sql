SELECT
  s.created as segement_created_timestamp
, date(s.created) as segement_created_date
, s.segment_id as segment_id_klaviyo
, s.name
FROM
  klaviyo_portable.klaviyo_v2_segments_8589937320 s
union
SELECT
  to_timestamp_ntz(ks.created) as segement_created_timestamp
, date(ks.created) as segement_created_date
, ks.id as segment_id_klaviyo
, ks.name
FROM
  klaviyo.segment ks