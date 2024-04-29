/*
Purpose: This table contains data about order attribution based on Klaviyo's configuration.
Transforms: This data is broken down into 1 CTE and a final query. The CTE is orders, which looks at all placed orders in
fact.klaviyo_events, and attributes them to a campaign or flow based on an attribute in the event_properties blob.
The final query cleans up the columns and brings in data from klaviyo dimensions to improve readability and usability
of this table.
About this data: According to Klaviyo's attribution model on 3/7/2024, the last email which was
Clicked or Opened within 4 days prior to placing an order, is attributed to the campaign. There is a setting in klaviyo
to change this. However, if marketing changes this setting, no change needs to be made to the code, because we pull
the attribution directly from klaviyo's json.
*/
with orders as
(
  SELECT
    ke.event_timestamp as order_timestamp
  , ke.event_date as order_date
  , ke.event_id_klaviyo
  , ke.order_id_shopify
  , ke.profile_id_klaviyo
  , ke.attributed_event_id_klaviyo
  , case when metric_name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(ke.event_properties,'"$attribution"."$flow"')::varchar else null end as attributed_flow_id_klaviyo
  , case when metric_name = 'Placed Order' then JSON_EXTRACT_PATH_TEXT(ke.event_properties,'$attribution.$campaign')::varchar else null end as attributed_campaign_id_klaviyo 
  , ke.total_amount
  , ke.subtotal_amount
  FROM
    fact.klaviyo_events ke
  WHERE
    ke.metric_name = 'Placed Order'  
)
  SELECT
    ke.campaign_id_klaviyo
  , kc.name as campaign_name
  , ke.flow_id_klaviyo
  , kf.name as flow_name
  , o.order_id_shopify
  , o.profile_id_klaviyo
  , o.total_amount
  , o.subtotal_amount
  , o.order_timestamp
  , o.order_date
  FROM
    orders o
  LEFT JOIN
    fact.klaviyo_events ke
    ON o.attributed_event_id_klaviyo = ke.event_id_klaviyo
  LEFT JOIN
    dim.klaviyo_campaigns kc
    on kc.campaign_id_klaviyo = ke.campaign_id_klaviyo
  LEFT JOIN
    dim.klaviyo_flows kf
    on kf.flow_id_klaviyo = ke.flow_id_klaviyo