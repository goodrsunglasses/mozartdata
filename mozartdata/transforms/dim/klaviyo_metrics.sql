/*
Purpose: This table contains meta data about klaviyo metrics. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
Transforms: all dates are natively in UTC, so I converted them to LA time.
About this data: Klaviyo Metrics are the various customer actions tracked in Klaviyo. To view the
activity use fact.klaivyo_events.
*/
SELECT
  m.created as created_timestamp
, date(m.created) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', m.created) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', m.created)) as created_date_pst
, m.metric_id as metric_id_klaviyo
, m.name as name
FROM
  klaviyo_portable.klaviyo_v2_metrics_8589937320 m
/*
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
*/
-- UNION ALL
-- SELECT
--   to_timestamp_ntz(km.created) as created_timestamp
-- , date(km.created) as created_date
-- , convert_timezone('UTC', 'America/Los_Angeles',to_timestamp_ntz(km.created)) as created_timestamp_pst
-- , date(convert_timezone('UTC', 'America/Los_Angeles', to_timestamp_ntz(km.created))) as created_date_pst
-- , km.id as metric_id_klaviyo
-- , km.name as name
-- FROM
--   klaviyo.metric km