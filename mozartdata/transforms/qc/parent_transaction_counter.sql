SELECT
  order_id_edw,
  SUM(
    salesorder_count + cashsale_count + invoice_count + purchaseorder_count
  ) agg_sum
FROM
  (
    SELECT
      order_id_edw,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'estimate' THEN transaction_id_ns
        END
      ) AS quote_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'vendorbill' THEN transaction_id_ns
        END
      ) AS bill_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'salesorder' THEN transaction_id_ns
        END
      ) AS salesorder_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'purchaseorder' THEN transaction_id_ns
        END
      ) AS purchaseorder_count,
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
          WHEN record_type = 'itemreceipt' THEN transaction_id_ns
        END
      ) AS itemreceipt_count,
      COUNT(
        DISTINCT CASE
          WHEN record_type = 'cashrefund' THEN transaction_id_ns
        END
      ) AS cashrefund_count
    FROM
      staging.order_item_detail
    WHERE
      createdfrom IS NULL and transaction_created_date_pst > '2022-01-01'
    GROUP BY
      order_id_edw
    HAVING
      salesorder_count = 1
      OR cashsale_count = 1
      OR invoice_count = 1
      OR purchaseorder_count = 1
  )
GROUP BY
  order_id_edw
HAVING
  agg_sum > 1
limit 400