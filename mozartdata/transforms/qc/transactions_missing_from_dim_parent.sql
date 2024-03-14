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
SELECT
  originals.transaction_id_ns original,
  parents.transaction_id_ns parented
FROM
  originals
  LEFT OUTER JOIN parents ON parents.transaction_id_ns = originals.transaction_id_ns
WHERE
  parented IS NULL