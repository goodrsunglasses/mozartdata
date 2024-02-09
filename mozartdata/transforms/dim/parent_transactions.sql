WITH
  order_ids AS ( --all order_id_ns's and their requisite transaction_id_ns's for dual usage later on (parent logic and child logic)
    SELECT DISTINCT
      order_id_ns,
      transaction_id_ns,
      createdfrom,
      record_type,
      transaction_created_timestamp_pst
    FROM
      staging.order_item_detail
  ),
  parent_ranking AS (
    SELECT
      order_id_ns,
      transaction_id_ns,
      createdfrom,
      record_type,
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
      (record_type = 'salesorder')
      OR (
        (
          record_type = 'cashsale'
          OR record_type = 'invoice'
        )
        AND createdfrom IS NULL
      )
      OR (
        record_type = 'purchaseorder'
        AND createdfrom IS NULL -- the idea here is that all the PO's that have no SO creating them are considered, while the PO's that are children of SO's are implicitly considered later
      )
  ),
  parent_type AS ( --quickly select the rank 1, so the most applicable parent's type for later sorting
    SELECT
      order_id_ns,
      record_type AS parent_type
    FROM
      parent_ranking
    WHERE
      RANK = 1
  ),
  final_ranking AS ( --finally rerank everything only for the transaction types that are the same as the rank 1 that was previously gotten, this is to prevent there for example being multiple parents with different record types like in SO1746720
    SELECT
      parent_ranking.order_id_ns,
      parent_ranking.transaction_id_ns,
      parent_ranking.record_type,
  createdfrom,
      parent_type
    FROM
      parent_ranking
      LEFT OUTER JOIN parent_type ON parent_type.order_id_ns = parent_ranking.order_id_ns
    WHERE
      record_type = parent_type
  ),
  transaction_tree AS (
    -- Anchor member: Select initial transactions that are parents (created_by is NULL)
    SELECT
      final_ranking.order_id_ns,
      final_ranking.transaction_id_ns,
      final_ranking.createdfrom,
      0 AS depth -- Initialize the path array with the transaction_id
    FROM
      final_ranking
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
  ),
  counter AS (
    SELECT
      order_id_ns,
      COUNT_IF(depth = 0) AS parent_count, -- Count parents
      COUNT_IF(depth = 1) AS child_count, -- Count children
      COUNT_IF(depth = 2) AS grandchild_count, -- Count grandchildren
      COUNT_IF(depth = 3) AS great_grandchildren_count -- Count grandchildren
    FROM
      transaction_tree
    WHERE
      order_id_ns IN (
        '113-7256776-6975450',
        'INT-2PURE091622-6.6K-1',
        'CS-DENVERGOV070722','PB-ST63168/SM'
      )
    GROUP BY
      order_id_ns
  )
select * from counter