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

Update: 2/17/2025 - updated to use v3 of Portable Klaviyo API
*/
--klaviyo Portable
with base as
(
 SELECT
    c.id as campaign_id_klaviyo
  , to_timestamp(c.attributes:CREATED_AT) as created_timestamp
  , to_timestamp(c.attributes:SCHEDULED_AT) as scheduled_timestamp
  , to_timestamp(c.attributes:SEND_TIME) as send_timestamp
  , c.attributes:NAME::string as name
  , c.attributes:STATUS::string as status
  , c.attributes:SEND_OPTIONS:IGNORE_UNSUBSCRIBES::boolean as ignore_unsubscribes_flag
  , c.attributes:AUDIENCES as audiences
  , c.attributes:SEND_OPTIONS:USE_SMART_SENDING::boolean as use_smart_sending_flag
  , c.attributes:SEND_STRATEGY:METHOD::varchar as send_strategy_method
  , to_timestamp(c.attributes:SEND_STRATEGY:OPTIONS_STATIC:DATETIME) as send_strategy_timestamp
  , c.attributes:SEND_STRATEGY:OPTIONS_STATIC:IS_LOCAL::boolean as send_strategy_is_local_flag
  , c.attributes:SEND_STRATEGY:OPTIONS_STATIC:SEND_PAST_RECIPIENTS_IMMEDIATELY::boolean as sent_strategy_past_recipients_immediately_flag
  , c.attributes:TRACKING_OPTIONS:IS_ADD_UTM::boolean as tracking_options_is_add_utm_flag
  , c.attributes:TRACKING_OPTIONS:CUSTOM_TRACKING_PARAMS as tracking_options_custom_tracking_parameters
  , c.attributes:TRACKING_OPTIONS:IS_TRACKING_CLICKS::boolean as tracking_options_is_tracking_clicks_flag
  , c.attributes:TRACKING_OPTIONS:IS_TRACKING_OPENS::boolean as tracking_options_is_tracking_opens_flag
  , to_timestamp(c.attributes:UPDATED_AT) as updated_timestamp
 FROM
     klaviyo_portable_v3_parallel.KLAVIYO_V3_CAMPAIGNS_8589938396 c
 )
SELECT
   b.campaign_id_klaviyo
  , b.created_timestamp
  , date(b.created_timestamp) as created_date
  , CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.created_timestamp) as created_timestamp_pst
  , date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.created_timestamp)) as created_date_pst
  , b.name
-- , c.message as message_id_klaviyo
  , b.status
  , b.scheduled_timestamp as scheduled_timestamp
  , date(b.scheduled_timestamp) as scheduled_date
  , b.send_timestamp as send_timestamp
  , date(b.send_timestamp) as send_date
  , case when b.send_strategy_is_local_flag then b.send_timestamp else CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.send_timestamp) end as send_timestamp_pst
  , case when b.send_strategy_is_local_flag then date(b.send_timestamp) else date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.send_timestamp)) end as send_date_pst
  , b.audiences
  , b.ignore_unsubscribes_flag
  , b.use_smart_sending_flag
  , b.send_strategy_method
  , b.send_strategy_timestamp
  , date(b.send_strategy_timestamp) as send_strategy_date
  , b.send_strategy_is_local_flag
  , b.sent_strategy_past_recipients_immediately_flag
  , b.tracking_options_is_add_utm_flag
  , b.tracking_options_custom_tracking_parameters
  , b.tracking_options_is_tracking_clicks_flag
  , b.tracking_options_is_tracking_opens_flag
  , b.updated_timestamp
  , date(b.updated_timestamp) as updated_date
  , CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.updated_timestamp) as updated_timestamp_pst
  , date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.updated_timestamp)) as updated_date_pst
FROM
  base b
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