SELECT 
  l.created as list_created_timestamp
, date(l.created) as list_created_date
, l.list_id as list_id_klaviyo
, l.name
, l.opt_in_process
FROM 
  klaviyo_portable.klaviyo_v2_lists_8589937320 l