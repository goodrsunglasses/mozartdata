SELECT
  ord.order_id_edw,
  shop.store channel_shopify,
  shop.order_created_timestamp_pst timestamp_shopify,
  shop.financial_status financial_status_shopify,
  shop.fulfillment_status,
  ns_line.record_type,
  ns_line.channel as channel_ns,
  ns_line.transaction_created_timestamp_pst timestamp_ns,
  stord.channel channel_stord,
  stord.inserted_at as inserted_at_stord,
  stord.status as status_stord
FROM
  dim.orders ord 
  left outer join fact.shopify_orders shop on shop.order_id_shopify = ord.order_id_shopify
  left outer join fact.order_line ns_line on ns_line.transaction_id_ns = ord.transaction_id_ns 
  left outer join stord.stord_sales_orders_8589936822 stord on stord.order_id = ord.stord_id