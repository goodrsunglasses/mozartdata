SELECT DISTINCT
  CONCAT(order_id_edw, '_', transaction_id_ns) AS order_line_id,
  item_detail.order_id_edw,
  item_detail.transaction_id_ns,
  item_detail.record_type,
  channel.name AS channel,
  entity AS customer_id_ns,
  customer.email,
  CASE
    WHEN record_type = 'cashrefund' THEN TRUE
    ELSE FALSE
  END AS has_refund,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  transaction_timestamp_pst,
  date(tran.trandate) as transaction_event_date,
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
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.transaction_id_ns
  left outer join dim.channel channel on channel.channel_id_ns = tran.cseg7
  LEFT OUTER JOIN netsuite.customer customer ON customer.id = tran.entity
WHERE
  record_type IN (
    'cashsale',
    'itemfulfillment',
    'salesorder',
    'cashrefund',
    'invoice'
  )