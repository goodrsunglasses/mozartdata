SELECT
  appl.order_id_shopify,
  appl.store,
  line.order_line_id_shopify,
  line.display_name,
  line.sku,
  appl.index,
  appl.type,
  appl.title,
  appl.discount_code,
  appl.value,
  appl.allocation_method,
  alloc.amount as amount_total_discount,
  case when appl.discount_code like 'YOTPO%' then true else false end as yotpo_discount_flag
   SUM(CASE
			   WHEN appl.discount_code NOT LIKE 'YOTPO%' THEN alloc.amount
			   WHEN appl.discount_code IS NULL AND appl.TITLE IS NOT NULL THEN alloc.amount
			   ELSE 0 END)                                                     AS amount_standard_discount,
 SUM(CASE WHEN appl.discount_code LIKE 'YOTPO%' then alloc.amount else 0 end) as amount_yotpo_discount
FROM
  staging.shopify_discount_application appl
  LEFT OUTER JOIN staging.shopify_order_line line ON line.order_id_shopify = appl.order_id_shopify and line.store = appl.store
  LEFT OUTER JOIN staging.shopify_discount_allocation alloc ON (
    alloc.order_line_id = line.order_line_id_shopify
    AND alloc.discount_application_index = appl.index
    AND alloc.store = appl.store
  )
