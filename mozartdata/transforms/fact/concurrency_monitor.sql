WITH
  ns_fulfill AS (
    SELECT
      order_id_edw,
      min(transaction_created_timestamp_pst) min_created_timestamp --using min here because the idea is that this is the "First" time the fulfillment was created in ns from stord (there could technically be multiple)
    FROM
      fact.order_line
    WHERE
      record_type = 'itemfulfillment'
    GROUP BY
      ALL
  )
SELECT
  ord.order_id_edw,
  shop.store channel_shopify,
  shop.order_created_timestamp_pst timestamp_shopify,
  shop.financial_status financial_status_shopify,
  shop.fulfillment_status,
  ns_line.record_type,
  ns_line.channel AS channel_ns,
  ns_line.transaction_created_timestamp_pst timestamp_ns,
  stord.channel channel_stord,
  CONVERT_TIMEZONE('UTC','America/Los_Angeles', stord.inserted_at) AS inserted_at_stord,
  CONVERT_TIMEZONE('UTC','America/Los_Angeles', stord.completed_at) AS completed_at_stord,
  stord.status AS status_stord,
    CASE
    WHEN inserted_at_stord IS NOT NULL THEN  min_created_timestamp
    ELSE NULL
  END AS ns_stord_fulfillment_creation, --the idea is that we only care about fulfillments in NS, that were in stord in the first place, to compare them
  DATEDIFF(MINUTE, timestamp_shopify, timestamp_ns) difference_shopify_ns,
  DATEDIFF(MINUTE, timestamp_shopify, inserted_at_stord) difference_shopify_stord,
  DATEDIFF(MINUTE, completed_at_stord, ns_stord_fulfillment_creation) difference_stord_ns,
  DATEDIFF(MINUTE, timestamp_shopify, completed_at_stord) shopify_click_stord_ship
FROM
  dim.orders ord
  LEFT OUTER JOIN fact.shopify_orders shop ON shop.order_id_shopify = ord.order_id_shopify
  LEFT OUTER JOIN fact.order_line ns_line ON ns_line.transaction_id_ns = ord.transaction_id_ns
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_id = ord.stord_id
  left outer join ns_fulfill on ns_fulfill.order_id_edw = ord.order_id_edw