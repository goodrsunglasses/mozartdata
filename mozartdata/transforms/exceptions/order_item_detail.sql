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
      order_id_edw in ('SG-CHIMAR2022','CS-LST-SD-G2501679')
    GROUP BY
      order_id_edw
    HAVING
      salesorder_count > 1
      OR cashsale_count > 1
      OR invoice_count > 1
      OR itemfulfillment_count > 1
      OR cashrefund_count > 1
  )