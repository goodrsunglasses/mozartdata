/*
Purpose: This table contains all campaigns as well as which lists and segments are included and excluded.
This data comes from an API connection set up through the vendor Portable which directly feeds the data into our
Snowflake db.
Transforms: This script is broken down into 3 CTES, one to capture which audiences are included, excluded and then
combine those CTEs. In the campaign table they use segment and list interchangeably, so the last query pulls relevant
information from klaviyo lists and klaviyo segments.
About this data: In Klaviyo, for every campaign the marketing team can select who should receive and who should NOT
receive a certain email. So this table shows that information.
*/
with excluded as
  (
SELECT
  c.campaign_id_klaviyo
, ex.value::varchar audience_id
, 'excluded' as type
FROM
  dim.KLAVIYO_CAMPAIGNS c,
LATERAL FLATTEN(input => c.audiences:EXCLUDED) ex
),
included as 
(
SELECT
  c.campaign_id_klaviyo
, inc.value::varchar audience_id
, 'included' as type
FROM
  dim.KLAVIYO_CAMPAIGNS c,
LATERAL FLATTEN(input => c.audiences:INCLUDED) inc
),
combined as
(
SELECT
  *
FROM
  excluded
UNION ALL
SELECT
  *
FROM
  included  
)
SELECT
  c.campaign_id_klaviyo
, ca.name as campaign_name
, audience_id
, case when l.LIST_ID_KLAVIYO is null then 'segment' else 'list' end audience_type
, type
FROM
  combined c
LEFT JOIN
  dim.KLAVIYO_CAMPAIGNS ca
  on c.campaign_id_klaviyo = ca.campaign_id_klaviyo
LEFT JOIN
  dim.klaviyo_lists l
  on audience_id = l.list_id_klaviyo