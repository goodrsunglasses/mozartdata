/*
conversion based on placed order
*/

SELECT
  e.datetime as event_timestamp
, convert_timezone('UTC', 'America/Los_Angeles', e.datetime) as event_timestamp_pst
, date(e.datetime) as event_date
, date(convert_timezone('UTC', 'America/Los_Angeles', e.datetime)) as event_date_pst
, e.event_id as event_id_klaviyo
, e.metric_id as metric_id_klaviyo
, m.name as metric_name
, e.profile_id as profile_id_klaviyo
, e.event_properties
, case when m.name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$event_id"')::varchar else null end as order_id_shopify
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$flow"')::varchar as flow_id_klaviyo
, case when JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$flow"')::varchar is null then JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$message"')::varchar end as campaign_id_klaviyo
, case when JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$flow"')::varchar is not null then JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$message"')::varchar end as flow_message_id_klaviyo
, case when metric_name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$attribution"."$attributed_event_id"')::varchar else null end as attributed_event_id_klaviyo
, case when metric_name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$attribution"."$flow"')::varchar else null end as attributed_flow_id_klaviyo
, case when metric_name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(e.event_properties,'$attribution.$campaign')::varchar else null end as attributed_campaign_id_klaviyo 
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Campaign Name"')::varchar as email_name
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Subject"')::varchar as subject
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Client Name"')::varchar as client_name
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Client OS"')::varchar as client_os
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Client OS Family"')::varchar asclient_os_family
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Client Type"')::varchar as client_type
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"Email Domai"')::varchar as email_domain
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"machine_open"')::boolean as machine_open_flag
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$extra"."current_total_price"')::varchar as total_amount
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$extra"."current_subtotal_price"')::varchar as subtotal_amount
, JSON_EXTRACT_PATH_TEXT(e.event_properties,'"$value"')::varchar as item_amount
FROM
  staging.klaviyo_events e
LEFT JOIN
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m
  on e.metric_id = m.metric_id
where metric_name = 'Placed Order'
-- UNION ALL
-- SELECT
--   to_timestamp_ntz(ke.datetime) as event_timestamp
-- , date(ke.datetime) as event_date
-- , ke.id as event_id_klaviyo
-- , ke.metric_id as metric_id_klaviyo
-- , km.name as metric_name
-- , ke.person_id as profile_id_klaviyo -->need to change this to a profile instead of person
-- , ke.campaign_id as campaign_id_klaviyo
-- , ke.property_event_id as order_id_shopify
-- , ke.property_value
-- , ke.property_total_discounts
-- , ke.property_shipping_rate
-- , ke.property_source_name
-- , ke.property_item_count
-- FROM
--   klaviyo.event ke
-- LEFT JOIN
--   klaviyo.metric km
--   on ke.metric_id = km.id