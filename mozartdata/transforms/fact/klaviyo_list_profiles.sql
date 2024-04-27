/*
Purpose: This table contains meta data about Klaviyo Lists. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: No transforms. Simple fact table of profiles and the list they are on.
About this data: This shows a list in klaviyo as well as all of the profiles (users) included in that list. Unlikely,
this table is used alone, it would likely be joined to dim.klaviyo_profiles to understand more about the included users.
*/
SELECT
  lp.list_id as list_id_klaviyo
, l.name as list_name
, lp.profile_id as profile_id_klaviyo
FROM 
  klaviyo_portable.klaviyo_v2_list_profiles_8589937320 lp
LEFT JOIN
  dim.klaviyo_lists l
  on lp.list_id = l.LIST_ID_KLAVIYO