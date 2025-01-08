SELECT tier, COALESCE(SUM(doors), 0) AS doors
FROM fact.customer_ns_map
WHERE last_order_date > '2023-12-31' 
  AND tier IS NOT NULL 
  AND tier <> 'Patrick Temple'
GROUP BY tier
  ORDER BY tier;