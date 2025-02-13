SELECT
  item.order_id_edw order_number,
  ord.channel,
  ord.location,
  ful.ship_date,
  item.sku,
  prod.display_name,
  item.quantity_stord quantity_shipped_stord,
  item.quantity_ns quantity_shipped_ns
FROM
  fact.fulfillment_item item
  LEFT OUTER JOIN fact.fulfillment ful ON ful.fulfillment_id_edw = item.fulfillment_id_edw
  left outer join fact.orders ord on ord.order_id_edw = ful.order_id_edw
  left outer join dim.product prod on prod.sku = item.sku 
WHERE
  quantity_stord IS NOT NULL
  AND quantity_ns IS NULL
  AND ship_date BETWEEN '2025-01-01T00:00:00' AND '2025-01-31T23:59:59'
and channel is not null