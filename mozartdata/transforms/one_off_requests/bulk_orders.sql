SELECT
  o.id,
  o.created_at,
  SUM(quantity) total_quantity,
  d.code,
  d.type,
    CASE
    WHEN total_quantity between 24 and 49 then 'small bulk'
    WHEN total_quantity between 50 and 99 then 'med bulk'
    WHEN  total_quantity between 100 and 500 then 'large bulk'
    ELSE 'huge bulk'
  END AS quantity_label
FROM
  shopify.order_line ol
  LEFT JOIN shopify."ORDER" o ON o.id = ol.order_id
  LEFT JOIN shopify.order_discount_code d ON o.id = d.order_id
WHERE
  o.created_at > '2023-03-31'
  AND o.created_at < '2023-08-31'
GROUP BY
  o.id,
  o.created_at,
  d.code,
  d.type
HAVING
  SUM(quantity) >= 24
ORDER BY
  created_at desc