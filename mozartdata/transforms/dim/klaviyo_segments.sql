/*
Purpose: This table contains meta data about Klaviyo Segments. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: all dates are natively in UTC, so I converted them to LA time. We joined to profiles to add
a simple count of profiles (users) in each list.
About this data: Klaviyo Segments are groups of customers (aka klaviyo profiles). Segments are
created and populated by the marketing team. Examples of lists include: Mach G Purchasers, LFG Interests,
2 Month Engaged.
Often times lists and segments are used interchangeably in Klaviyo.
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
*/
SELECT
  s.created as created_timestamp
, date(s.created) as created_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.created) as created_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.created)) as created_date_pst
, s.segment_id as segment_id_klaviyo
, s.name
, s.updated as updated_timestamp
, date(s.updated) as updated_date
, CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.updated) as updated_timestamp_pst
, date(CONVERT_TIMEZONE('UTC','America/Los_Angeles',s.updated)) as updated_date_pst
FROM
  klaviyo_portable.klaviyo_v2_segments_8589937320 s
/*
Note: The second half of the union was joining to the original fivetran data pulled from
July 2023 - Jan 2024. However,  this data was incomplete and inconsistent with Portable's data
so the decision was made to just start fresh in 2024 with Portable.
*/
-- union
-- SELECT
--   to_timestamp_ntz(ks.created) as segement_created_timestamp
-- , date(ks.created) as segement_created_date
-- , ks.id as segment_id_klaviyo
-- , ks.name
-- FROM
--   klaviyo.segment ks