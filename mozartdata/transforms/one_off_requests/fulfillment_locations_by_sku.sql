SELECT
  sum(oi.quantity_fulfilled) as quantity_fulfilled,
  oi.product_id_edw,
  oi.sku,
  oi.plain_name,
  o.location,
  o.channel,
  o.fulfillment_date
FROM
  fact.order_item oi
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
WHERE
  --- fulfillment in prior month
  o.fulfillment_date >= DATEADD('MONTH', -1, DATE_TRUNC('MONTH', CURRENT_DATE))
  AND sold_date < DATE_TRUNC('MONTH', CURRENT_DATE)
GROUP BY
  oi.product_id_edw,
  oi.sku,
  oi.plain_name,
  o.location,
  o.channel,
  o.fulfillment_date