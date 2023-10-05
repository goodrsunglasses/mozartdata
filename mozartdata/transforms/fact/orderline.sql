SELECT DISTINCT
  item_detail.order_id_edw,
  item_detail.recordtype,
  item_detail.id,
  cseg7,
  SUM(full_quantity) over (
    PARTITION BY
      order_id_edw,
      item_detail.id
  ) AS total_quantity,
  timestamp_transaction_pst
FROM
  fact.order_item_detail item_detail
  LEFT OUTER JOIN netsuite.transaction tran ON tran.id = item_detail.id