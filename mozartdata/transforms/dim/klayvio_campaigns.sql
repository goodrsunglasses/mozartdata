/*
options sto
options throttled
01HNT4X6WZZVYDZ98H544KDP34
*/
--Klayvio Portable (February 2024+)
SELECT
  c.*
  c.campaign_id as campaign_id_klayvio
, c.created_at as campaign_created_timestamp
, date(c.created_at) as campaign_created_date
, c.name as name
, c.message as message_id_klayvio
, c.status
, c.scheduled_at as scheduled_timestamp
, date(c.scheduled_at) as scheduled_date
, c.send_time as send_timestamp
, date(c.send_time) as send_date
, c.send_options:IGNORE_UNSUBSCRIBES::boolean as ignore_unsubscribes_flag
, c.send_options:USE_SMART_SENDING::boolean as use_smart_sending_flag
, c.send_strategy:METHOD::varchar as send_strategy_method
, c.send_strategy:METHOD:DATETIME:timestamp as send_strategy_timestamp
, c.send_strategy:METHOD:DATETIME:date as send_strategy_date
, c.send_strategy:METHOD:IS_LOCAL:boolean as send_strategy_is_local_flag
, c.send_strategy:METHOD:SEND_PAST_RECIPIENTS_IMMEDIATELY:boolean as sent_strategy_past_recipients_immediately_flag
, c.tracking_options:IS_ADD_UTM:boolean as tracking_options_is_add_utm_flag
, c.tracking_options:IS_TRACKING_CLICKS:boolean as tracking_options_is_tracking_clicks_flag
, c.tracking_options:IS_TRACKING_OPENS:boolean as tracking_options_is_tracking_clicks_flag
FROM
  klaviyo_portable.klaviyo_v2_campaigns_8589937320 c

  
UNION ALL
--Klayvio Fivetran (July 2023 - January 2024)
SELECT
  ck.id as campaign_id_klayvio
, to_timestamp_ntz(ck.created_at) as campaign_created_timestamp
, date(ck.created_at) as campaign_created_date
, ck.name as name
, c.message as message_id_klayvio
, c.status
, c.scheduled_at as scheduled_timestamp
, date(c.scheduled_at) as scheduled_date
, c.send_time as send_timestamp
, date(c.send_time) as send_date
, c.send_options:IGNORE_UNSUBSCRIBES::boolean as ignore_unsubscribes_flag
, c.send_options:USE_SMART_SENDING::boolean as use_smart_sending_flag
, c.send_strategy:METHOD::varchar as send_strategy_method
, c.send_strategy:METHOD:DATETIME:timestamp as send_strategy_timestamp
, c.send_strategy:METHOD:DATETIME:date as send_strategy_date
, c.send_strategy:METHOD:IS_LOCAL:boolean as send_strategy_is_local_flag
, c.send_strategy:METHOD:SEND_PAST_RECIPIENTS_IMMEDIATELY:boolean as sent_strategy_past_recipients_immediately_flag
, c.tracking_options:IS_ADD_UTM:boolean as tracking_options_is_add_utm_flag
, c.tracking_options:IS_TRACKING_CLICKS:boolean as tracking_options_is_tracking_clicks_flag
, c.tracking_options:IS_TRACKING_OPENS:boolean as tracking_options_is_tracking_clicks_flag
FROM
  klaviyo_portable.klaviyo_v2_campaigns_8589937320 ck
inner join
klaviyo.campaign zendesk.ticket
select * from klaviyo.campaign