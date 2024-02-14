SELECT 
  e.timestamp as exclusion_timestamp
, date(e.timestamp) as exclusion_date
, e.email
, e.object as type
, e.reason

FROM 
  klaviyo_portable.klaviyo_v2_global_exclusions_8589937320 e