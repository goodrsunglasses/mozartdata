-- WITH
--   draft AS -- put the draft version or w/e of the table you wanna select in here if needed
--   (
--     WITH
--       shopify AS (
--         SELECT
--           DATE_TRUNC(YEAR, DATE(o.created_at)) order_year,
--           SUM(ol.quantity) quantity
--         FROM
--           shopify."ORDER" o
--           INNER JOIN shopify.order_line ol ON o.id = ol.order_id
--         WHERE
--           order_year <= '2021-01-01'
--         GROUP BY
--           DATE_TRUNC(YEAR, DATE(o.created_at))
--         ORDER BY
--           order_year
--       ),
--       specialty AS (
--         SELECT
--           DATE_TRUNC(YEAR, DATE(o.created_at)) order_year,
--           SUM(ol.quantity) quantity
--         FROM
--           specialty_shopify."ORDER" o
--           LEFT JOIN specialty_shopify.order_line ol ON o.id = ol.order_id
--         WHERE
--           order_year <= '2021-01-01'
--         GROUP BY
--           DATE_TRUNC(YEAR, DATE(o.created_at))
--         ORDER BY
--           order_year
--       )
--     SELECT
--       DATE_TRUNC(YEAR, o.sold_date) order_year,
--       SUM(quantity_sold) quantity
--     FROM
--       draft_fact.orders o
--     WHERE
--       channel = 'Goodr.com'
--     GROUP BY
--       DATE_TRUNC(YEAR, o.sold_date)
--     UNION ALL
--     (
--       SELECT
--         s.order_year,
--         s.quantity + ss.quantity
--       FROM
--         shopify s
--         INNER JOIN specialty ss ON s.order_year = ss.order_year
--     )
--     ORDER BY
--       order_year
--   )
SELECT
  'Version 1 Only' AS source,
  v1.*
FROM
  dim.parent_transactions v1
  LEFT JOIN draft_dim.parent_transactions draft ON v1.transaction_id_ns = draft.transaction_id_ns
WHERE
  draft.transaction_id_ns IS NULL
UNION ALL
SELECT
  'Version 2 Only' AS source,
  draft.*
FROM
   draft_dim.parent_transactions draft
  LEFT JOIN dim.parent_transactions v1 on v1.transaction_id_ns = draft.transaction_id_ns
WHERE
  v1.transaction_id_ns IS NULL