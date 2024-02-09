WITH
  order_ids AS (
    SELECT DISTINCT
      order_id_ns,
      transaction_id_ns,
      createdfrom,
      record_type,
  transaction_created_timestamp_pst
    FROM
      staging.order_item_detail
  )
  -- ,
  -- ranking as (
  select 
  order_id_ns,
  transaction_id_ns,
  createdfrom,
  ROW_NUMBER() OVER (
    PARTITION BY
      order_id_ns
    ORDER BY
      CASE record_type
        WHEN 'salesorder' THEN 1
        WHEN 'cashsale' THEN 2
        WHEN 'invoice' THEN 2
        WHEN 'purchaseorder' THEN 3
        ELSE 4
      END,
      transaction_created_timestamp_pst
  ) AS RANK
FROM
  order_ids
WHERE
  order_id_ns IN ('113-7256776-6975450', 'INT-2PURE091622-6.6K-1','PB-ST63168/SM')
  -- )
  -- transaction_tree AS (
  --   -- Anchor member: Select initial transactions that are parents (created_by is NULL)
  --   SELECT
  --     order_ids.order_id_ns,
  --     order_ids.transaction_id_ns,
  --     order_ids.createdfrom,
  --     0 AS depth -- Initialize the path array with the transaction_id
  --   FROM
  --     order_ids
  --   WHERE
  --     order_ids.createdfrom IS NULL
  --   UNION ALL
  --   -- Recursive member: Join to find child transactions
  --   SELECT
  --     order_ids_2.order_id_ns,
  --     order_ids_2.transaction_id_ns,
  --     order_ids_2.createdfrom,
  --     tt.depth + 1 AS depth
  --   FROM
  --     order_ids order_ids_2
  --     JOIN transaction_tree tt ON order_ids_2.createdfrom = tt.transaction_id_ns
  -- ),
  -- counter AS (
  --   SELECT
  --     order_id_ns,
  --     COUNT_IF(depth = 0) AS parent_count, -- Count parents
  --     COUNT_IF(depth = 1) AS child_count, -- Count children
  --     COUNT_IF(depth = 2) AS grandchild_count, -- Count grandchildren
  --     COUNT_IF(depth = 3) AS great_grandchildren_count -- Count grandchildren
  --   FROM
  --     transaction_tree
  --   WHERE
  --     order_id_ns IN (
  --       '113-7256776-6975450',
  --       'INT-2PURE091622-6.6K-1',
  --       'CS-DENVERGOV070722'
  --     )
  --   GROUP BY
  --     order_id_ns
  -- )