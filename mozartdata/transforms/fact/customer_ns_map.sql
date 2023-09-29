SELECT
  id,
  entityid,
  customer_id_edw
FROM
  --Maybe join to netsuite.transactions and get their channel to get customer category and double join to dim.customers?
  netsuite.customer ns_cust
  LEFT OUTER JOIN draft_dim.customers customers ON customers.email = ns_cust.email