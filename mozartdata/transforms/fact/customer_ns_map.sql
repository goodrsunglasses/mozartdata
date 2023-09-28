SELECT
  id,
  entityid,
  customer_id_edw
FROM
  netsuite.customer ns_cust
  LEFT OUTER JOIN draft_dim.customers customers ON customers.email = ns_cust.email