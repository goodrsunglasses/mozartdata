WITH
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
      status,
      province,
      city,
      zip,
      country,
      estimated_delivery_at,
      happened_at,
      message
    FROM
      shopify.fulfillment_event fulfill_event
      LEFT OUTER JOIN shopify."ORDER" shop_order ON shop_order.id = fulfill_event.order_id
  ),
  ns_order AS (
    SELECT
      order_id,
      channel,
      date_tran,
      actualShipDate,
      location
    FROM
      dim.orders
  )
SELECT DISTINCT
  order_id,
  channel,
  location,
  date_tran AS click, --using this as click its also date_created from Shopeify, so when the order is created
  coalesce(actualShipDate,createdate) AS ship, --using coalesce to grab the first non null value, meaning that it will grab the shipstation ship date just in case it doesn't exist in NS for whatever reason
  datediff (HOUR, click, ship) / 24.0 AS click_to_ship,
  MAX(estimated_delivery_at) OVER (
    PARTITION BY
      order_id
  ) AS est_delivery
FROM
  ns_order
  LEFT OUTER JOIN ss_shipments ON ss_shipments.order_num = ns_order.order_id
  LEFT OUTER JOIN shop_fulfill ON shop_fulfill.order_num = ns_order.order_id
where click >= '2022-01-01T00:00:00Z' --filtered to ignore alot of early weird data from NS/Shopify