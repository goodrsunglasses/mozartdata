-- CREATE OR REPLACE TABLE fact.shopify_discount_item
--            COPY GRANTS  as
SELECT
  appl.order_id_shopify,
  line.order_line_id_shopify,
  line.display_name,
  line.sku,
  appl.index,
  appl.type,
  appl.title,
  appl.discount_code,
  appl.value,
  appl.allocation_method,
  alloc.amount
FROM
  staging.shopify_discount_application appl
  LEFT OUTER JOIN staging.shopify_order_line line ON line.order_id_shopify = appl.order_id_shopify
  LEFT OUTER JOIN staging.shopify_discount_allocation alloc ON (
    alloc.order_line_id = line.order_line_id_shopify
    AND alloc.discount_application_index = appl.index
  )
WHERE
  appl.order_id_shopify = 5349398511674