SELECT
  orders.order_id_edw,
  orders.order_id_ns,
  orders.store,
  line.transaction_date
FROM
  dim.orders orders
  LEFT OUTER JOIN fact.order_line line ON orders.order_id_edw = line.order_id_edw
WHERE
  stord_id IS NOT NULL
  AND shipstation_id IS NOT NULL
and transaction_date >= '2024-01-01'