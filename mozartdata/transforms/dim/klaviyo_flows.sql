/*
Purpose: This table contains meta data about klaviyo flows. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time.
About this data: Klaviyo Flows are automated (or manual) email workflows which are sent to customers
(or potential customers). Examples include reminders for abandoned carts, new customer flows, reminders
for customers who haven't purchased recently. etc. Unlike campaigns, these are more evergreen and not
focused on a specific campaign

Update: 2/17/2025 updated code to use v3 API
*/
with base as
(
  SELECT
    to_timestamp(f.attributes:CREATED::INT) as created_timestamp
  , f.id as flow_id_klaviyo
  , f.attributes:NAME::STRING as name
  , f.attributes:STATUS::STRING as status
  , f.attributes:TRIGGER_TYPE::STRING as trigger_type
  , f.attributes:ARCHIVED::boolean as archive_flag
  , to_timestamp(f.attributes:UPDATED::INT) as updated_timestamp
  FROM
    klaviyo_portable_v3_parallel.KLAVIYO_V3_FLOWS_8589938396 f
)
select
  b.created_timestamp
, date(b.created_timestamp) as created_date
, convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp) as created_timestamp_pst
, date(convert_timezone('UTC', 'America/Los_Angeles', b.created_timestamp)) as created_date_pst
, b.flow_id_klaviyo
, b.name
, b.status
, b.trigger_type
, b.archive_flag
from
  base b