SELECT
  parents.custom_id as order_id_edw,
  staging.order_id_edw as og_order_id_edw,
  staging.transaction_id_ns,
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
  exceptions.dupe_flag
FROM
  dim.parent_transactions parents
  left outer join staging.order_item_detail staging on staging.order_id_edw = parents.order_id_edw
  LEFT OUTER JOIN exceptions.order_item_detail exceptions ON exceptions.transaction_id_ns = staging.transaction_id_ns
WHERE
  (
    dupe_flag IS NULL
    OR dupe_flag = FALSE
  )