WITH
  sold AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
      item_id_ns,
      transaction_timestamp_pst,
      plain_name,
      total_quantity,
      location
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'salesorder'
      AND item_type = 'InvtPart'
      AND order_id_edw = 'SO0958613'
  ), 
  fulfilled  (
    SELECT
      order_id_edw,
      transaction_id_ns,
      item_id_ns,
      transaction_timestamp_pst,
      plain_name,
      total_quantity,
      location
    FROM
      fact.order_item_detail
    WHERE
      record_type = 'itemfulfillment'
      AND item_type = 'InvtPart'
      AND order_id_edw = 'SO0958613'
  )
ORDER BY
  ordernum asc
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.location loc ON loc.id = tranline.location
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
  LEFT OUTER JOIN fact.order_item_detail detail ON (
    detail.transaction_id_ns = tran.id
    AND detail.item_id_ns = tranline.item
  )