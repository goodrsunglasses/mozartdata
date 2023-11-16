SELECT *, c.customer_id_ns
FROM fact.orders o
  join fact.customer_ns_map c on o.customer_id_edw = c.customer_id_edw
WHERE channel = 'Specialty'
order by order_id_edw desc