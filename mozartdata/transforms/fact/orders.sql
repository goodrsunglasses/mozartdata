WITH
  priority AS (
    SELECT
      order_id_edw,
      FIRST_VALUE(id) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN recordtype = 'cashsale' THEN 1
            WHEN recordtype = 'invoice' THEN 2
            WHEN recordtype = 'salesorder' THEN 3
            ELSE 4
          END,
          timestamp_transaction_pst ASC
      ) AS id
    FROM
      fact.orderline
  ),
  order_level AS (
    SELECT distinct
      priority.order_id_edw,
      priority.id,
      channel,
      timestamp_transaction_pst,
    FROM
      priority
      LEFT OUTER JOIN fact.orderline orderline ON (
        orderline.id = priority.id
        AND orderline.order_id_edw = priority.order_id_edw
      )
  )
SELECT
  *
FROM
  order_level