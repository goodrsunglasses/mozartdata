/*
Purpose: This table contains meta data about klaviyo lists. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time. We joined to profiles to add
a simple count of profiles (users) in each list.
About this data: Klaviyo Lists are groups of customers (aka klaviyo profiles). Lists are
created and populated by the marketing team. Examples of lists include: FLAM 2024 Members, Beast Segment,
Whiskey BIS.
Often times lists and segments are used interchangeably in Klaviyo.

Update: 2/17/2025 - Updated to V3 of API
*/
WITH base as
(
  SELECT
    to_timestamp(l.attributes:CREATED::INT) as created_timestamp
  , l.id as list_id_klaviyo
  , l.attributes:NAME::STRING as name
  , l.attributes:OPT_IN_PROCESS::string as opt_in_process
  , to_timestamp(l.attributes:UPDATED::INT) as updated_timestamp
FROM
  klaviyo_portable_v3_parallel.KLAVIYO_V3_LISTS_8589938396 l
)
SELECT
  b.created_timestamp
, date(b.created_timestamp) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.created_timestamp) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', b.created_timestamp)) as created_date_pst
, b.list_id_klaviyo
, b.name
, b.opt_in_process
, count(distinct lp.id) profile_count
, b.updated_timestamp
FROM 
  base b
LEFT JOIN
  klaviyo_portable_v3_parallel.KLAVIYO_V3_LIST_PROFILES_8589938396 lp
  on b.list_id_klaviyo = lp.list_id
GROUP BY ALL