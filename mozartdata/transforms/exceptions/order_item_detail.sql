WITH
  first_pass AS ( --This is the first pass that just limits the query to the transactions that have an odd count of transactions
    SELECT
      order_id_edw,
      COUNT(
        CASE
          WHEN record_type = 'salesorder' THEN transaction_id_ns
        END
      ) AS salesorder_count,
      COUNT(
        CASE
          WHEN record_type = 'cashsale' THEN transaction_id_ns
        END
      ) AS cashsale_count,
      COUNT(
        CASE
          WHEN record_type = 'invoice' THEN transaction_id_ns
        END
      ) AS invoice_count,
      COUNT(
        CASE
          WHEN record_type = 'itemfulfillment' THEN transaction_id_ns
        END
      ) AS itemfulfillment_count,
      COUNT(
        CASE
          WHEN record_type = 'cashrefund' THEN transaction_id_ns
        END
      ) AS cashrefund_count
    FROM
      fact.order_item_detail
    WHERE
      order_id_edw IN ('SG-CHIMAR2022', 'CS-LST-SD-G2501679')
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
    SELECT
      *
    FROM
      first_pass
    WHERE
      salesorder_count > 1
  )
SELECT --Here I'll have it select the original full list, then join with it depending on what CTE it came from and have there be a final boolean that will determine if te transaction_id_ns should be excluded
  order_id_edw
FROM
  first_pass 
left outer join if_dupes, left outer join so_dupes