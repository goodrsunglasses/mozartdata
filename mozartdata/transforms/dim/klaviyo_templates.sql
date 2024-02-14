SELECT
  t.created as template_created_timestamp
, date(t.created) as template_created_date
, t.template_id as template_id_klaviyo
, t.html
, t.name
FROM klaviyo_portable.klaviyo_v2_templates_8589937320 t