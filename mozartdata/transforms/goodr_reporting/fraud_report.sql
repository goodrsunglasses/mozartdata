SELECT
  r.score as risk_score,
  r.recommendation,
  o.*
FROM
  shopify.order_risk r
  LEFT JOIN shopify."ORDER" o ON o.id = r.order_id
WHERE
  r.score > 0
ORDER BY created_at desc