WITH
  order_ids AS (
    SELECT DISTINCT
      order_id_ns,
      transaction_id_ns,
      record_type,
      createdfrom
    FROM
      staging.order_item_detail
  ),
  transaction_tree AS (
    -- Anchor member: Select initial transactions that are parents (created_by is NULL)
    SELECT
      order_ids.order_id_ns,
      order_ids.transaction_id_ns,
      order_ids.createdfrom,
      0 AS depth -- Initialize the path array with the transaction_id
    FROM
      order_ids
    WHERE
      order_ids.createdfrom IS NULL
    UNION ALL
    -- Recursive member: Join to find child transactions
    SELECT
      order_ids_2.order_id_ns,
      order_ids_2.transaction_id_ns,
      order_ids_2.createdfrom,
      tt.depth + 1 AS depth
    FROM
      order_ids order_ids_2
      JOIN transaction_tree tt ON order_ids_2.createdfrom = tt.transaction_id_ns
  )
SELECT
  order_id_ns,
  COUNT_IF(depth = 0) AS parent_count, -- Count parents
  COUNT_IF(depth = 1) AS child_count, -- Count children
  COUNT_IF(depth = 2) AS grandchild_count -- Count grandchildren
FROM
  transaction_tree
WHERE
  order_id_ns = '113-7256776-6975450'
GROUP BY
  order_id_ns
ORDER BY
  order_id_ns