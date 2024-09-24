WITH
  sunglass_orders AS (
    SELECT DISTINCT
      (order_id_edw)
    FROM
      fact.order_item oi
      LEFT JOIN dim.product AS p ON oi.product_id_edw = p.product_id_edw
    WHERE
      p.merchandise_department = 'SUNGLASSES'
  )
SELECT
  o.*,
  c.customer_name,
FROM
  fact.orders AS o
  INNER JOIN sunglass_orders so ON so.order_id_edw = o.order_id_edw
  LEFT JOIN fact.customer_ns_map AS c ON o.customer_id_ns = c.customer_id_ns
WHERE
  o.b2b_d2c = 'B2B'
  AND o.sold_date > '2023-12-31'
  AND revenue > 0