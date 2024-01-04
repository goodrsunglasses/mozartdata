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
where order_id_edw = 'SG-CHIMAR2022'
group by order_id_edw