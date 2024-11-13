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
  CONVERT_TIMEZONE('America/Los_Angeles', stord.inserted_at) AS inserted_at_stord,
  stord.status AS status_stord,
  DATEDIFF(MINUTE, timestamp_shopify, timestamp_ns) difference_shopify_ns,
  DATEDIFF(MINUTE, timestamp_shopify, inserted_at_stord) difference_shopify_stord
FROM
  dim.orders ord
  LEFT OUTER JOIN fact.shopify_orders shop ON shop.order_id_shopify = ord.order_id_shopify
  LEFT OUTER JOIN fact.order_line ns_line ON ns_line.transaction_id_ns = ord.transaction_id_ns
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_id = ord.stord_id
WHERE
  date(coalesce(timestamp_shopify, timestamp_ns)) >= '2023-01-01'