SELECT
  order_id_edw,
  'Odd transaction record count' as reason,
  LISTAGG(DISTINCT emp.entityid, ', ') who_touched_this,
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
  fact.order_line line
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = line.transaction_id_ns
  LEFT OUTER JOIN netsuite.employee emp ON tran.createdby = emp.id
WHERE
  channel = 'Customer Service'
  and 
  transaction_timestamp_pst >= '2023-11-03T00:00:00Z'
GROUP BY
  order_id_edw,
  reason
HAVING
  salesorder_count > 1
  OR cashsale_count > 1
  OR invoice_count > 1
  OR itemfulfillment_count > 1
  OR cashrefund_count > 1
UNION ALL
SELECT
  order_id_edw,
  'Odd Naming Convention' as reason,
  LISTAGG(DISTINCT emp.entityid, ', ') modifiers,
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
  fact.order_line line
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = line.transaction_id_ns
  LEFT OUTER JOIN netsuite.employee emp ON tran.createdby = emp.id
WHERE
  channel = 'Customer Service'
  AND transaction_timestamp_pst >= '2023-11-03T00:00:00Z'
  AND LOWER(order_id_edw) NOT LIKE '%cs-%'
  AND order_id_edw NOT LIKE '%SD-%'
  AND order_id_edw NOT LIKE '%CI-%'
  AND order_id_edw NOT LIKE '%DON-%'
GROUP BY
  order_id_edw,
reason