SELECT
  s.name,
  s.created_at,
  o.order_id_edw
FROM
  goodrwill_shopify."ORDER" s
  LEFT JOIN fact.orders o ON s.name = o.order_id_edw
WHERE
  o.order_id_edw IS NULL
  and s.created_at > '2024-01-01'