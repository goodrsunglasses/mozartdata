SELECT 
  f.created as flow_created_timestamp
, date(f.created) as flow_created_date
, f.flow_id as flow_id_klayvio
, f.name
, f.status
, f.trigger_type
, f.archived as archive_flag
FROM 
  klaviyo_portable.klaviyo_v2_flows_8589937320 f