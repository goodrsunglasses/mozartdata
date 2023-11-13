WITH
  priority AS (
    SELECT DISTINCT
      order_id_edw,
      FIRST_VALUE(transaction_id_ns) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'purchaseorder' THEN 1
            ELSE 2
          END,
          transaction_timestamp_pst ASC
      ) AS id
    FROM
      fact.purchase_order_line
  ),
  order_level AS (
    SELECT DISTINCT
      priority.order_id_edw,
      priority.id,
      vendor_id_ns,
      name,
      transaction_timestamp_pst
    FROM
      priority
      LEFT OUTER JOIN fact.purchase_order_line orderline ON (
        orderline.transaction_id_ns = priority.id
        AND orderline.order_id_edw = priority.order_id_edw
      )
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_ordered
          ELSE 0
        END
      ) AS quantity_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_billed
          ELSE 0
        END
      ) AS quantity_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_received
          ELSE 0
        END
      ) AS quantity_received,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_ordered
          ELSE 0
        END
      ) AS rate_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_billed
          ELSE 0
        END
      ) AS rate_billed,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_ordered
          ELSE 0
        END
      ) AS amount_ordered,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_billed
          ELSE 0
        END
      ) AS amount_billed
    FROM
      fact.purchase_order_item
    GROUP BY
      order_id_edw
  )
SELECT
  order_level.order_id_edw,
  order_level.name,
  order_level.vendor_id_ns,
  order_level.transaction_timestamp_pst AS order_timestamp_pst,
  DATE(order_level.transaction_timestamp_pst) AS order_date_pst,
  quantity_ordered,
  quantity_billed,
  quantity_received,
  rate_ordered,
  rate_billed,
  amount_ordered,
  amount_billed
FROM
  order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw
WHERE
  order_level.transaction_timestamp_pst >= '2022-01-01T00:00:00Z'
ORDER BY
  order_level.transaction_timestamp_pst desc