SELECT primary_sport, SUM(doors) AS doors
FROM fact.customer_ns_map
WHERE last_order_date > '2023-12-31' AND primary_sport IS NOT NULL AND doors < 1000000
GROUP BY primary_sport