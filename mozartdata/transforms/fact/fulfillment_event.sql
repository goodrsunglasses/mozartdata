WITH
  distinct_order_info AS (
    SELECT DISTINCT
      order_id_edw,
      channel,
      timestamp_transaction_pst
    FROM
      dim.orders
  ),
  ns_shipments AS (
    SELECT DISTINCT
      custbody_goodr_shopify_order order_num,
      actualshipdate
    FROM
      netsuite.transaction
  ),
  ss_shipments AS (
    SELECT
      ordernumber AS order_num,
      createdate
    FROM
      shipstation_portable.shipstation_shipments_8589936627 shipments
  ),
  shop_fulfill AS (
    SELECT
      shop_order.name AS order_num,
       MAX(estimated_delivery_at) OVER (
    PARTITION BY
      order_id
  ) AS est_delivery,
      happened_at,
      message
    FROM
      shopify.fulfillment_event fulfill_event
      LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id
  )
SELECT DISTINCT
  order_id_edw,
  channel,

  
 
FROM
  distinct_order_info
  LEFT OUTER JOIN ss_shipments ON ss_shipments.order_num = distinct_order_info.order_id
  LEFT OUTER JOIN shop_fulfill ON shop_fulfill.order_num = distinct_order_info.order_id
WHERE
  timestamp_transaction_pst >= '2022-01-01T00:00:00Z' --filtered to ignore alot of early weird data from NS/Shopify