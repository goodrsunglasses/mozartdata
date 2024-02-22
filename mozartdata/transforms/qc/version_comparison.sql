WITH
  draft AS -- put the draft version or w/e of the table you wanna select in here if needed
  (
    WITH
      shopify AS (
        SELECT
          DATE_TRUNC(YEAR, DATE(o.created_at)) order_year,
          SUM(ol.quantity) quantity
        FROM
          shopify."ORDER" o
          INNER JOIN shopify.order_line ol ON o.id = ol.order_id
        WHERE
          order_year <= '2021-01-01'
        GROUP BY
          DATE_TRUNC(YEAR, DATE(o.created_at))
        ORDER BY
          order_year
      ),
      specialty AS (
        SELECT
          DATE_TRUNC(YEAR, DATE(o.created_at)) order_year,
          SUM(ol.quantity) quantity
        FROM
          specialty_shopify."ORDER" o
          LEFT JOIN specialty_shopify.order_line ol ON o.id = ol.order_id
        WHERE
          order_year <= '2021-01-01'
        GROUP BY
          DATE_TRUNC(YEAR, DATE(o.created_at))
        ORDER BY
          order_year
      )
    SELECT
      DATE_TRUNC(YEAR, o.sold_date) order_year,
      SUM(quantity_sold) quantity
    FROM
      draft_fact.orders o
    WHERE
      channel = 'Goodr.com'
    GROUP BY
      DATE_TRUNC(YEAR, o.sold_date)
    UNION ALL
    (
      SELECT
        s.order_year,
        s.quantity + ss.quantity
      FROM
        shopify s
        INNER JOIN specialty ss ON s.order_year = ss.order_year
    )
    ORDER BY
      order_year
  )
SELECT
  'Version 1 Only' AS source,
  v1.*
FROM
  one_off_requests.historical_quantity_sold v1
  LEFT JOIN draft ON v1.order_year = draft.order_year
WHERE
  draft.order_year IS NULL
UNION ALL
SELECT
  'Version 2 Only' AS source,
  draft.*
FROM
  draft
  LEFT JOIN one_off_requests.historical_quantity_sold v1 ON v1.order_year = draft.order_year
WHERE
  v1.order_year IS NULL