SELECT
  o.*,
  c.customer_id_ns,
  c.company_name
FROM
  Fact.Orders o
  LEFT JOIN fact.customer_ns_map c ON o.customer_id_edw = c.customer_id_edw
WHERE
  booked_date BETWEEN '2023-01-01' AND '2024-01-01'
  AND channel = 'Key Account'
  and order_id_edw like 'PB%'