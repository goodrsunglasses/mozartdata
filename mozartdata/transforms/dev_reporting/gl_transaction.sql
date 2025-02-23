SELECT DISTINCT
  gt.gl_transaction_id_edw
, gt.order_id_edw
, gt.order_id_ns
, gt.transaction_id_ns
, gt.transaction_number_ns
, gt.record_type
, gt.account_id_edw
, gt.account_id_ns
, gt.transaction_line_id_ns
, gt.account_number
, gt.budget_category
, gt.channel
, gt.transaction_timestamp
, gt.transaction_date
, gt.transaction_timestamp_pst
, gt.transaction_date_pst
, gt.date_posted_pst
, gt.posting_flag
, gt.posting_period
, gt.transaction_amount
, gt.credit_amount
, gt.debit_amount
, gt.normal_balance_amount
, gt.net_amount
, gt.parent_transaction_id_ns
, gt.item_id_ns
, gt.product_id_edw
, gt.customer_id_ns
, gt.customer_id_edw
, gt.tier
, gt.department_id_ns
, gt.department
, gt.memo
, gt.line_memo
, gt.line_entity
, gt.line_entity_type
, gt.entity
, gt.entity_type
, gt.line_class
, gt.cleared_flag
, gt.cleared_date
, gt.order_id_shopify
, CASE
    WHEN o.tier LIKE '%O' AND o.b2b_d2c = 'B2B' THEN TRUE
    WHEN cust.first_order_id_edw_shopify IS NOT NULL THEN TRUE
    ELSE FALSE END AS new_customer_order_flag
FROM
  fact.gl_transaction gt
  LEFT JOIN
    fact.orders o
  ON o.order_id_edw = gt.order_id_edw
  LEFT OUTER JOIN fact.customers cust
  ON cust.first_order_id_edw_shopify = gt.order_id_edw
  AND cust.customer_category = 'D2C'