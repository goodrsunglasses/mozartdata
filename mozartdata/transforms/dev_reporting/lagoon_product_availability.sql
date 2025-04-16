WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.netsuite_bin_inventory
  ),
  transfer_info AS (
    SELECT
      transfer_order_number_ns,
      transfer_order_transaction_id_ns,
      transaction_date,
  status,
  memo,
  product_id_edw,
  item_id_ns,
  total_quantity
    FROM
      fact.transfer_order_item_detail
  )
SELECT
  *
FROM
  binventory
WHERE
  bin_id = 2519
  AND sku = 'OG-HND-NRBR1'