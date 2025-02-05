SELECT
  *
FROM
  shopify.order_risk --- shows risk score
SELECT
  *
FROM
  shopify.order_risk_fact -- descriptions 
SELECT
  *
FROM
  shopify.order_risk_summary --- rec
SELECT
  *
FROM
  shopify.order_risk_assessment
  ------
SELECT
  *
FROM
  shopify.order_risk
  --  where order_id = '5451090886714'
WHERE
  score = 1
SELECT DISTINCT
  score
FROM
  shopify.order_risk --- 0, 0.5, 1
  -------------
SELECT
  r.score as risk_score,
  o.*
FROM
  shopify.order_risk r
  LEFT JOIN shopify."ORDER" o ON o.id = r.order_id
WHERE
  r.score > 0
ORDER BY created_at desc