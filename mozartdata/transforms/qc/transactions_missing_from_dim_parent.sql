WITH
  originals AS (
    SELECT DISTINCT
      transaction_id_ns
    FROM
      staging.order_item_detail
  ),
  parents AS (
    SELECT DISTINCT
      transaction_id_ns
    FROM
      dim.parent_transactions
  )
SELECT DISTINCT
  detail.order_id_ns,
  detail.record_type,
  originals.transaction_id_ns original,
  parents.transaction_id_ns parented,
  detail.transaction_created_date_pst DATE
FROM
  originals
  LEFT OUTER JOIN parents ON parents.transaction_id_ns = originals.transaction_id_ns
  LEFT OUTER JOIN staging.order_item_detail detail ON detail.transaction_id_ns = originals.transaction_id_ns
WHERE
  parented IS NULL
  AND DATE >= '2024-01-01'