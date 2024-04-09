with net_amount as
  (
    select
      gt.transaction_id_ns
    , gt.item_id_ns
    , sum(gt.net_amount) net_amount
    from
      fact.gl_transaction gt
    where
      gt.account_number between 4000 and 4999
    group by
      gt.transaction_id_ns
    , gt.item_id_ns
  ),
sales_tax as
  (
    select
      gt.transaction_id_ns
    , gt.item_id_ns
    , sum(gt.net_amount) net_amount
    from
      fact.gl_transaction gt
    where
      gt.account_number between 2200.01 and 2200.99
    group by
      gt.transaction_id_ns
    , gt.item_id_ns
  )

SELECT
  parents.order_id_edw,
  staging.order_id_ns,
  staging.transaction_id_ns,
  parents.is_parent,
  order_item_detail_id,
  product_id_edw,
  staging.item_id_ns,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  staging.record_type,
  full_status,
  item_type,
  plain_name,
  coalesce(na.net_amount,st.net_amount) as net_amount,
  total_quantity,
  quantity_invoiced,
  quantity_backordered,
  unit_rate,
  rate,
  gross_profit_estimate,
  cost_estimate,
  location,
  createdfrom,
  staging.warranty_order_id_ns,
  exception_flag
FROM
  dim.parent_transactions parents
  LEFT OUTER JOIN staging.order_item_detail staging ON staging.transaction_id_ns = parents.transaction_id_ns
  LEFT OUTER JOIN exceptions.order_item_detail exceptions ON exceptions.transaction_id_ns = parents.transaction_id_ns
  LEFT OUTER JOIN net_amount na on staging.transaction_id_ns = na.transaction_id_ns and staging.item_id_ns = na.item_id_ns
  LEFT OUTER JOIN sales_tax st on staging.transaction_id_ns = st.transaction_id_ns and staging.item_id_ns = st.item_id_ns
WHERE
  exception_flag = FALSE