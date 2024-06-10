SELECT DISTINCT
  CONCAT(order_id_edw, '_', transaction_id_ns) AS order_line_id,
  item_detail.order_id_edw,
  item_detail.order_id_ns,
  item_detail.transaction_id_ns,
  item_detail.is_parent,
  item_detail.record_type,
  entity AS vendor_id_edw,
  entity AS vendor_id_ns,
  vendors.name,
  transaction_created_timestamp_pst,
  DATE(tran.trandate) AS transaction_date,
  CASE
    WHEN full_status LIKE ANY(
      '%Closed',
      '%Voided',
      '%Undefined',
      '%Rejected',
      '%Unapproved',
      '%Not Deposited'
    ) THEN TRUE
    ELSE FALSE
  END AS status_flag_edw
FROM
  draft_fact.order_item_detail item_detail
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.transaction_id_ns
  LEFT OUTER JOIN dim.vendors vendors ON vendors.vendor_id_edw = tran.entity
WHERE
  tran.recordtype IN ('purchaseorder', 'vendorbill', 'itemreceipt')