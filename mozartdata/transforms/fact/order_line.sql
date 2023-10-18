SELECT DISTINCT
  CONCAT(order_id_edw,'_', order_id_ns) AS order_line_id,
  item_detail.order_id_edw,
  item_detail.order_id_ns,
  item_detail.record_type,
  channel.name AS channel,
  entity as customer_id_ns,
  customer.email,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  transaction_timestamp_pst,
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
  fact.order_item_detail item_detail
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.item_id_ns
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.customer customer ON customer.id = tran.entity