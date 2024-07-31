SELECT
  iid.transaction_id_ns,
  iid.transaction_number_ns,
  iid.record_type,
  iid.channel,
  iid.location_id_ns,
  iid.location_name,
  iid.transaction_created_date_pst,
  iid.item_id_ns,
  iid.sku,
  iid.plain_name,
  iid.quantity,
  sum(gt.net_amount) net_amount
FROM
  fact.inventory_item_detail iid
LEFT JOIN
  fact.gl_transaction gt
  ON iid.transaction_id_ns = gt.transaction_id_ns
  AND iid.transaction_line_id_ns = gt.transaction_line_id_ns
  AND gt.posting_flag
WHERE
  iid.record_type = 'inventoryadjustment'
GROUP BY
  iid.transaction_id_ns,
  iid.transaction_number_ns,
  iid.record_type,
  iid.channel,
  iid.location_id_ns,
  iid.location_name,
  iid.transaction_created_date_pst,
  iid.item_id_ns,
  iid.sku,
  iid.plain_name,
  iid.quantity