SELECT
  parents.order_id_edw,
  staging.order_id_ns,
  staging.transaction_id_ns,
  parents.is_parent,
  order_item_detail_id,
  product_id_edw,
  item_id_ns,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  staging.record_type,
  full_status,
  item_type,
  plain_name,
  net_amount,
  total_quantity,
  quantity_invoiced,
  quantity_backordered,
  unit_rate,
  rate,
  gross_profit_estimate,
  cost_estimate,
  location,
  createdfrom,
  exception_flag
FROM
  dim.parent_transactions parents
  LEFT OUTER JOIN staging.order_item_detail staging ON staging.transaction_id_ns = parents.transaction_id_ns
  LEFT OUTER JOIN exceptions.order_item_detail exceptions ON exceptions.transaction_id_ns = parents.transaction_id_ns
WHERE
  exception_flag = FALSE