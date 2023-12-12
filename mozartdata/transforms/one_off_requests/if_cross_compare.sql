SELECT
  item.order_id_edw,
  booked_date,
  quantity_booked,
  quantity_fulfilled,
  total_quantity
FROM
  fact.orders item
  LEFT OUTER JOIN fact.fulfillment fulfill ON fulfill.order_id_edw = item.order_id_edw
WHERE
  booked_date >= '2023-12-01'
  AND total_quantity != quantity_booked
  AND quantity_booked != quantity_fulfilled and is_exchange = false