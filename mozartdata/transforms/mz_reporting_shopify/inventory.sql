-- Get details on changes to the inventory each day from the order_lines and orders tables.

SELECT
  o.processed_timestamp,
  ol.inventory_item_id,
  ol.product_id,
  ol.variant_id,
  ol.sku,
  ol.name,
  ol.title,
  ol.variant_title,
  ol.vendor,
  ol.price,
  ol.variant_price,
  ol.quantity,
  ol.variant_inventory_management,
  ol.variant_inventory_quantity,
  ol.grams,
  ol.variant_is_requiring_shipping
FROM
  mz_reporting_shopify.order_lines ol
  LEFT JOIN mz_reporting_shopify.orders o ON ol.order_id = o.order_id
ORDER BY 1