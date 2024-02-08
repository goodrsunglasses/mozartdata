/*
options sto
options throttled
01HNT4X6WZZVYDZ98H544KDP34
*/
--klaviyo Portable (February 2024+)
SELECT
  c.campaign_id as campaign_id_klaviyo
, c.created_at as campaign_created_timestamp
, date(c.created_at) as campaign_created_date
, c.name as name
, c.message as message_id_klaviyo
, c.status
, c.scheduled_at as scheduled_timestamp
, date(c.scheduled_at) as scheduled_date
, c.send_time as send_timestamp
, date(c.send_time) as send_date
, c.send_options:IGNORE_UNSUBSCRIBES::boolean as ignore_unsubscribes_flag
, c.send_options:USE_SMART_SENDING::boolean as use_smart_sending_flag
, c.send_strategy:METHOD::varchar as send_strategy_method
--, c.send_strategy:METHOD:DATETIME:timestamp as send_strategy_timestamp
--, c.send_strategy:METHOD:DATETIME:date as send_strategy_date
, c.send_strategy:METHOD:IS_LOCAL:boolean as send_strategy_is_local_flag
, c.send_strategy:METHOD:SEND_PAST_RECIPIENTS_IMMEDIATELY:boolean as sent_strategy_past_recipients_immediately_flag
, c.tracking_options:IS_ADD_UTM:boolean as tracking_options_is_add_utm_flag
, c.tracking_options:IS_TRACKING_CLICKS:boolean as tracking_options_is_tracking_clicks_flag
, c.tracking_options:IS_TRACKING_OPENS:boolean as tracking_options_is_tracking_opens_flag
FROM
  klaviyo_portable.klaviyo_v2_campaigns_8589937320 c  
UNION ALL
--klaviyo Fivetran (July 2023 - January 2024)
SELECT
  ck.id as campaign_id_klaviyo
, to_timestamp_ntz(ck.created) as campaign_created_timestamp
, date(ck.created) as campaign_created_date
, ck.name as name
, ck.email_template_id as message_id_klaviyo
, ck.status
, to_timestamp_ntz(ck.send_time) as scheduled_timestamp
, date(ck.send_time) as scheduled_date
, to_timestamp_ntz(ck.sent_at) as send_timestamp
, date(ck.sent_at) as send_date
, ck.send_option_ignore_unsubscribes as ignore_unsubscribes_flag
, ck.send_option_use_smart_sending as use_smart_sending_flag
, ck.send_strategy_method as send_strategy_method
--, ck.send_strategy_options_static_datetime as send_strategy_timestamp
-- , date(ck.send_strategy_options_static_datetime) as send_strategy_date
, ck.send_strategy_options_static_is_local as send_strategy_is_local_flag
, ck.send_strategy_options_static_send_past_recipients_immediately as sent_strategy_past_recipients_immediately_flag
, ck.tracking_options_is_add_utm as tracking_options_is_add_utm_flag
, ck.tracking_options_is_tracking_clicks as tracking_options_is_tracking_clicks_flag
, ck.tracking_options_is_tracking_opens as tracking_options_is_tracking_opens_flag
FROM
  klaviyo.campaign ck