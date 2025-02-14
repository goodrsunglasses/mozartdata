SELECT
  item.order_id_edw order_number,
  ord.channel,
  ord.location,
  ful.ship_date,
  REGEXP_REPLACE(item.sku, '-v\\d+$', '') AS fixed_sku,
  prod.display_name,
  item.quantity_stord quantity_shipped_stord,
  quantity_fulfilled_ns 
FROM
  fact.fulfillment_item item
  LEFT OUTER JOIN fact.fulfillment ful ON ful.fulfillment_id_edw = item.fulfillment_id_edw
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = ful.order_id_edw
  LEFT OUTER JOIN dim.product prod ON prod.sku = REGEXP_REPLACE(item.sku, '-v\\d+$', '')
WHERE
  quantity_stord IS NOT NULL
  and fulfillment_date_ns is null
  AND channel IS NOT NULL
ORDER BY
  ship_date desc