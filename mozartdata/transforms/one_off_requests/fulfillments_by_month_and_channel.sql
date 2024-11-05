SELECT
  warehouse_location,
  o.channel,
  date_trunc(month, ship_date) as ship_month,
  count(fulfillment_id_edw) fulfillments
FROM
  fact.fulfillment f
  LEFT JOIN fact.orders o ON o.order_id_edw = f.order_id_edw
WHERE ship_date >= '2023-01-01'
GROUP BY ALL