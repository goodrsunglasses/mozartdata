/*
Purpose: This table contains meta data about klaviyo campaigns. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
Transforms: all dates are natively in UTC, so I converted them to LA time.
About this data: Klaviyo Campaigns are targeted email marketing campaigns. They can be scheduled to send
at a specific time locally or universally. eg.  9 AM PST (so 12 ET) or 9 AM everywhere, and the emails
are sent at their respective times based on customer location. The send_strategy_is_local_flag indicates
how this campaign will be sent.
*/
--klaviyo Portable
SELECT
  c.campaign_id as campaign_id_klaviyo
, c.created_at as created_timestamp
, date(c.created_at) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.created_at) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.created_at)) as created_date_pst
, c.name as name
, c.message as message_id_klaviyo
, c.status
, c.scheduled_at as scheduled_timestamp
, date(c.scheduled_at) as scheduled_date
, c.send_time as send_timestamp
, date(c.send_time) as send_date
, case when c.send_strategy:OPTIONS_STATIC:IS_LOCAL::boolean then c.send_time else CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.send_time) end as send_timestamp_pst
, case when c.send_strategy:OPTIONS_STATIC:IS_LOCAL::boolean then date(c.send_time) else date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.send_time)) end as send_date_pst
, c.send_options:IGNORE_UNSUBSCRIBES::boolean as ignore_unsubscribes_flag
, c.send_options:USE_SMART_SENDING::boolean as use_smart_sending_flag
, c.send_strategy:METHOD::varchar as send_strategy_method
--, c.send_strategy:METHOD:DATETIME:timestamp as send_strategy_timestamp
--, c.send_strategy:METHOD:DATETIME:date as send_strategy_date
, c.send_strategy:OPTIONS_STATIC:IS_LOCAL::boolean as send_strategy_is_local_flag
, c.send_strategy:OPTIONS_STATIC:SEND_PAST_RECIPIENTS_IMMEDIATELY::boolean as sent_strategy_past_recipients_immediately_flag
, c.tracking_options:IS_ADD_UTM::boolean as tracking_options_is_add_utm_flag
, c.tracking_options:IS_TRACKING_CLICKS::boolean as tracking_options_is_tracking_clicks_flag
, c.tracking_options:IS_TRACKING_OPENS::boolean as tracking_options_is_tracking_opens_flag
, c.updated_at as updated_timestamp
, date(c.updated_at) as updated_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.updated_at) as updated_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', c.updated_at)) as updated_date_pst
FROM
  klaviyo_portable.klaviyo_v2_campaigns_8589937320 c
/*
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
*/
-- UNION ALL
-- --klaviyo Fivetran (July 2023 - January 2024)
-- SELECT
--   ck.id as campaign_id_klaviyo
-- , to_timestamp_ntz(ck.created) as campaign_created_timestamp
-- , date(ck.created) as campaign_created_date
-- , ck.name as name
-- , ck.email_template_id as message_id_klaviyo
-- , ck.status
-- , to_timestamp_ntz(ck.send_time) as scheduled_timestamp
-- , date(ck.send_time) as scheduled_date
-- , to_timestamp_ntz(ck.sent_at) as send_timestamp
-- , date(ck.sent_at) as send_date
-- , ck.send_option_ignore_unsubscribes as ignore_unsubscribes_flag
-- , ck.send_option_use_smart_sending as use_smart_sending_flag
-- , ck.send_strategy_method as send_strategy_method
-- --, ck.send_strategy_options_static_datetime as send_strategy_timestamp
-- -- , date(ck.send_strategy_options_static_datetime) as send_strategy_date
-- , ck.send_strategy_options_static_is_local as send_strategy_is_local_flag
-- , ck.send_strategy_options_static_send_past_recipients_immediately as sent_strategy_past_recipients_immediately_flag
-- , ck.tracking_options_is_add_utm as tracking_options_is_add_utm_flag
-- , ck.tracking_options_is_tracking_clicks as tracking_options_is_tracking_clicks_flag
-- , ck.tracking_options_is_tracking_opens as tracking_options_is_tracking_opens_flag
-- FROM
--   klaviyo.campaign ck