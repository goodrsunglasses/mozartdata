SELECT 
  l.created as created_timestamp
, date(l.created) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created)) as created_date_pst
, l.list_id as list_id_klaviyo
, l.name
, l.opt_in_process
FROM 
  klaviyo_portable.klaviyo_v2_lists_8589937320 l