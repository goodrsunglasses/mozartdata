SELECT
  o.customer_id_edw,
  SUM(o.amount_sold) as amount_ytd,
  d1.year,
  cm.customer_id_ns
FROM
  fact.orders o
  LEFT JOIN dim.date d1 ON o.sold_date = d1.date
  LEFT JOIN fact.customer_ns_map cm on o.customer_id_edw = cm.customer_id_edw
WHERE
  o.model = 'Wholesale'
  AND d1.year IN (2022, 2023)
GROUP BY 
  o.customer_id_edw,
  cm.customer_id_ns,
  d1.year