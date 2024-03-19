/* According to Klaviyo's attribution model on 3/7/2024, the last email which was Clicked or Opened within 4 days prior to placing an order, is attributed to the campaign*/
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
, attribution as
(
  SELECT
    o.*
  , ke.event_timestamp
  , ke.campaign_id_klaviyo
  , kc.name as campaign_name
  , ke.flow_id_klaviyo
  , kf.name as flow_name
  , ke.metric_name
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
)
SELECT
  a.campaign_id_klaviyo
, a.campaign_name
, a.flow_id_klaviyo
, a.flow_name
, a.order_id_shopify 
, a.profile_id_klaviyo 
, a.total_amount
, a.subtotal_amount
, a.order_timestamp
, a.order_date
FROM
  attribution a