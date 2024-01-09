WITH
  first_pass AS ( --This is the first pass that just limits the query to the transactions that have an odd count of transactions
    SELECT
      order_id_edw,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'salesorder' THEN transaction_id_ns
        END
      ) AS salesorder_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'cashsale' THEN transaction_id_ns
        END
      ) AS cashsale_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'invoice' THEN transaction_id_ns
        END
      ) AS invoice_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'itemfulfillment' THEN transaction_id_ns
        END
      ) AS itemfulfillment_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'cashrefund' THEN transaction_id_ns
        END
      ) AS cashrefund_count
    FROM
      staging.order_item_detail
    GROUP BY
      order_id_edw
    HAVING
      salesorder_count > 1
      OR cashsale_count > 1
      OR invoice_count > 1
      OR itemfulfillment_count > 1
      OR cashrefund_count > 1
  ),
  if_dupes AS ( --Selecting all the IF dupes for tracking related checks
    SELECT
      *
    FROM
      first_pass
    WHERE
      itemfulfillment_count > 1
  ),
  so_dupes AS ( -- Selecting all the SO Dupes for parent_transaction related sorting
    SELECT DISTINCT
      first_pass.order_id_edw,
      transaction_id_ns,
      FIRST_VALUE(transaction_id_ns) OVER (
        PARTITION BY
          first_pass.order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'salesorder'
            AND createdfrom IS NULL THEN 1
            WHEN record_type IN ('cashsale', 'invoice')
            AND createdfrom IS NULL THEN 2
            ELSE 3
          END,
          transaction_created_timestamp_pst ASC
      ) AS parent_id,
      CASE
        WHEN createdfrom IS NULL
        AND transaction_id_ns != parent_id THEN TRUE
        WHEN createdfrom != parent_id THEN TRUE
        ELSE FALSE
      END AS dupe_flag
    FROM
      first_pass
      LEFT OUTER JOIN staging.order_item_detail detail ON detail.order_id_edw = first_pass.order_id_edw
    WHERE
      salesorder_count > 1
  )
SELECT --Here I'll have it select the original full list, then join with it depending on what CTE it came from and have there be a final boolean that will determine if te transaction_id_ns should be excluded
  first_pass.*,
  so_dupes.transaction_id_ns,
  so_dupes.dupe_flag
FROM
  first_pass
  LEFT OUTER JOIN so_dupes ON so_dupes.order_id_edw = first_pass.order_id_edw