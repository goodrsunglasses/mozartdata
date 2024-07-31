SELECT
  transaction_id_ns,
  transaction_number_ns,
  record_type,
  channel,
  location_id_ns,
  location_name,
  transaction_created_date_pst,
  sku,
  plain_name,
  quantity
FROM
  fact.inventory_item_detail
WHERE
  record_type = 'inventoryadjustment'