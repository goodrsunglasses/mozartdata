SELECT DISTINCT
  MD5(CONCAT(order_id_edw, ns_id)) AS orderline_id,
  item_detail.order_id_edw,
  item_detail.recordtype,
  item_detail.ns_id,
  channel.name AS channel,
  entity customer_id,
  customer.email,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  timestamp_transaction_pst,
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
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.ns_id
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id
  LEFT OUTER JOIN netsuite.customer customer ON customer.id = tran.entity