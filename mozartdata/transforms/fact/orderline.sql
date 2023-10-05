SELECT distinct
  order_id_edw,
  recordtype,
  id,
  SUM(full_quantity) over (
    PARTITION BY
      order_id_edw,
      id
  ) AS total_quantity,
  timestamp_transaction_pst

FROM
  fact.order_item_detail