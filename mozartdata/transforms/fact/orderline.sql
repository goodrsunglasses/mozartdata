SELECT DISTINCT
  item_detail.order_id_edw,
  item_detail.recordtype,
  item_detail.id,
  channel.name AS channel,
  entity customer_id,
  CASE
    WHEN memo LIKE '%RMA%' THEN TRUE
    ELSE FALSE
  END AS is_exchange,
  SUM(full_quantity) over (
    PARTITION BY
      order_id_edw,
      item_detail.id
  ) AS total_quantity,
  timestamp_transaction_pst
FROM
  fact.order_item_detail item_detail
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.id
  LEFT OUTER JOIN netsuite.customrecord_cseg7 channel ON tran.cseg7 = channel.id