SELECT tier, SUM(doors) AS doors
FROM fact.customer_ns_map
WHERE last_order_date > '2023-12-31' AND tier IS NOT NULL
  GROUP BY tier;