/*
Purpose: This table contains meta data about klaviyo metrics. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
Transforms: all dates are natively in UTC, so I converted them to LA time.
About this data: Klaviyo Metrics are the various customer actions tracked in Klaviyo. To view the
activity use fact.klaivyo_events.

Update: 2/16/2025
We are migrating from v2 to v3 of the API. Updating code to align with the new data model.
*/
WITH
  base as
    (
      SELECT
        to_timestamp(m.attributes:CREATED::int) as created_timestamp
      , to_timestamp(m.attributes:UPDATED::int) as updated_timestamp
      , m.*
      FROM
        klaviyo_portable_v3_parallel.klaviyo_v3_metrics_8589938396 m
    )
SELECT
    b.id as metric_id_klaviyo
  , b.created_timestamp
  , date(b.created_timestamp) as created_date
  , convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp) as created_timestamp_pst
  , date(convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp)) as created_date_pst
  , b.attributes:NAME::text as name
  , b.updated_timestamp
  , date(b.updated_timestamp) as updated_date
FROM
  base b
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