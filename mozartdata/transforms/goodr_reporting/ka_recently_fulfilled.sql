SELECT 
  o.*,
  c.customer_id_ns,
  c.customer_name
FROM fact.orders o
  LEFT JOIN fact.customer_ns_map c on c.customer_id_edw = o.customer_id_edw
WHERE 
  o.channel = 'Key Account' 
  and o.fulfillment_date >= '2024-01-01'
ORDER BY fulfillment_date desc