/*
Purpose: This table contains meta data about Klaviyo Exclusions. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms:all dates are natively in UTC, so I converted them to LA time.
About this data: This shows when a user is added to an exclusion list and why. Generally they are marking our emails
as spam or unsubscribing.
*/
SELECT
  e.timestamp as exclusion_timestamp
, convert_timezone('UTC', 'America/Los_Angeles', e.timestamp) as exclusion_timestamp_pst
, date(e.timestamp) as exclusion_date
, date(convert_timezone('UTC', 'America/Los_Angeles', e.timestamp)) as exclusion_date_pst
, e.email
, e.object as type
, e.reason

FROM 
  klaviyo_portable.klaviyo_v2_global_exclusions_8589937320 e