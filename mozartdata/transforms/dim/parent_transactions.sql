--This table went through a shitload of iterations and can definitly be more efficient in its line count but it has such stringent logic that breaking it up into multiple CTE's made the most sense
WITH
  distinct_order_lines AS ( --sanitize the data to just transaction level information from order_item_detail for later ranking
    SELECT DISTINCT
      order_id_edw,
      transaction_id_ns,
      transaction_created_timestamp_pst,
      record_type,
      createdfrom
    FROM
      staging.order_item_detail
    WHERE
      order_id_edw IN (
        'PB-ST63168/SM',
        '113-7256776-6975450',
        'G2361579',
        'SO1746720'
      )
  )
  ,
  first_select AS ( --first select the applicable records based on the where clause then rank them based on transaction type
    SELECT
      order_id_edw,
      record_type,
      transaction_id_ns,
      transaction_created_timestamp_pst,
      ROW_NUMBER() OVER (
        PARTITION BY
          order_id_edw
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
      distinct_order_lines
    WHERE
      (record_type = 'salesorder')
      OR (
        (
          record_type = 'cashsale'
          OR record_type = 'invoice'
        )
        AND createdfrom IS NULL
      )
      OR (record_type = 'purchaseorder')
  ),
  parent_type AS ( --quickly select the rank 1, so the most applicable parent's type for later sorting
    SELECT
      order_id_edw,
      record_type AS parent_type
    FROM
      first_select
    WHERE
      RANK = 1
  ),
  final_ranking as (--finally rerank
SELECT
  first_select.order_id_edw,
  parent_type,
  first_select.record_type,
  first_select.transaction_id_ns,
  ROW_NUMBER() OVER (
    PARTITION BY
      first_select.order_id_edw
    ORDER BY
      transaction_created_timestamp_pst
  ) AS final_rank,
  COUNT(*) OVER (
    PARTITION BY
      first_select.order_id_edw
  ) AS cnt
FROM
  first_select
  LEFT OUTER JOIN parent_type ON parent_type.order_id_edw = first_select.order_id_edw
WHERE
  record_type = parent_type
  )
  -- SELECT --finally concatenate based on the logic of all sales orders first, then cashsales/invoices, then Purchaseorders
  --   order_id_edw,
  --   record_type,
  --   transaction_id_ns AS parent_id,
  --   CASE
  --     WHEN MAX(
  --       CASE
  --         WHEN record_type = 'salesorder'
  --         AND RANK = 1 THEN 1
  --         ELSE 0
  --       END
  --     ) OVER (
  --       PARTITION BY
  --         order_id_edw,
  --         transaction_id_ns
  --     ) = 1
  --     AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
  --     WHEN MAX(
  --       CASE
  --         WHEN record_type IN ('cashsale', 'invoice')
  --         AND RANK = 1 THEN 1
  --         ELSE 0
  --       END
  --     ) OVER (
  --       PARTITION BY
  --         order_id_edw,
  --         transaction_id_ns
  --     ) = 1
  --     AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
  --     WHEN MAX(record_type = 'purchaseorder') OVER (
  --       PARTITION BY
  --         order_id_edw,
  --         transaction_id_ns
  --     ) = 1
  --     AND cnt > 1 THEN CONCAT(order_id_edw, '#', RANK)
  --     ELSE order_id_edw
  --   END AS custom_id
  -- FROM
  --   ranking