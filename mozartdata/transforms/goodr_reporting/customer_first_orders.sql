SELECT
    o.*, 
  case when o.tier like '%O' and b2b_d2c = 'B2B' then true
       when cust.first_order_id_edw_ns is not null and cust.customer_category = 'D2C' then TRUE
       else false end as customer_first_order_flag
FROM
  fact.orders o
  LEFT OUTER JOIN fact.customers cust ON cust.first_order_id_edw_ns = o.order_id_edw