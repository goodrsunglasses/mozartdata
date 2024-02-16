SELECT 
  f.created as flow_created_timestamp
, date(f.created) as flow_created_date
, convert_timezone('UTC', 'America/Los_Angeles', f.created) as flow_created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', f.created)) as flow_created_date_pst
, f.flow_id as flow_id_klayvio
, f.name
, f.status
, f.trigger_type
, f.archived as archive_flag
FROM 
  klaviyo_portable.klaviyo_v2_flows_8589937320 f