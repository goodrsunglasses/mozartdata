WITH
  collection_cte AS (
    SELECT
      sku,
      CASE
        WHEN sku IN ('G00237-OG-LB1-RF', 'G00273-OG-RS2-RF') THEN 'RUN CHICAGO + DC'
        WHEN sku IN (
          'G00252-OG-BO1-RF',
          'G00253-OG-GD6-RF',
          'G00254-OG-GD7-RF'
        ) THEN 'DAZED & CONFUSED'
        WHEN sku IN ('G00287-OG-BK1-NR') THEN 'EXERCISE THE DEMONS'
        WHEN sku IN ('G00274-OG-BK1-GR') THEN 'RUN NYC'
        WHEN sku IN ('G00264-OG-LLB2-RF') THEN 'BREAKING SILENCE'
        WHEN sku IN ('G00296-OG-GR1-GR', 'G00297-OG-BR1-NR') THEN 'MONSTERS'
        ELSE NULL
      END AS collection
    FROM
      draft_dim.product
  )
SELECT
  p.sku,
  collection_cte.collection,
  SUM(o.amount_sold),
  COUNT()
FROM
  fact.orders o
  INNER JOIN fact.order_item oi ON o.order_id_edw = oi.order_id_edw
  INNER JOIN draft_dim.product p ON p.item_id_ns = oi.item_id_ns
  INNER JOIN collection_cte ON collection_cte.sku = p.sku
GROUP BY
  p.sku,
  collection_cte.collection
ORDER BY
  collection