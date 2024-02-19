SELECT
  t.created as created_timestamp
, date(t.created) as reated_date
, convert_timezone('UTC','America/Los_Angeles',t.created) as created_timestamp_pst
, date(convert_timezone('UTC','America/Los_Angeles',t.created)) as created_date_pst
, t.template_id as template_id_klaviyo
, t.html
, t.name
, t.updated as updated_timestamp
, date(t.updated) as updated_date
, convert_timezone('UTC','America/Los_Angeles',t.updated) as updated_timestamp_pst
, date(convert_timezone('UTC','America/Los_Angeles',t.updated)) as updated_date_pst
FROM klaviyo_portable.klaviyo_v2_templates_8589937320 t