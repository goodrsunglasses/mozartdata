/*
Purpose: This table contains meta data about klaviyo lists. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time. We joined to profiles to add
a simple count of profiles (users) in each list.
About this data: Klaviyo Lists are groups of customers (aka klaviyo profiles). Lists are
created and populated by the marketing team. Examples of lists include: FLAM 2024 Members, Beast Segment,
Whiskey BIS.
Often times lists and segments are used interchangeably in Klaviyo.
*/
SELECT
  l.created as created_timestamp
, date(l.created) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created)) as created_date_pst
, l.list_id as list_id_klaviyo
, l.name
, l.opt_in_process
, count(distinct lp.profile_id) profile_count
FROM 
  klaviyo_portable.klaviyo_v2_lists_8589937320 l
LEFT JOIN
  klaviyo_portable.klaviyo_v2_list_profiles_8589937320 lp
  on l.list_id = lp.list_id
GROUP BY
  l.created
, date(l.created)
, CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created)
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles', l.created))
, l.list_id
, l.name
, l.opt_in_process