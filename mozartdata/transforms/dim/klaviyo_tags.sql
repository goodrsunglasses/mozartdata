/*
Purpose: This table contains meta data about Klaviyo Tags. This data comes from an API connection
set up through the vendor Portable which directly feeds the data into our Snowflake db.
Transforms: This is a direct copy of the portable table. No transforms.
About this data: Tags are used to categorize klaviyo messages.
*/
SELECT
  t.tag_id as tag_id_klaviyo 
, t.name
FROM klaviyo_portable.klaviyo_v2_tags_8589937320 t