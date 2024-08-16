WITH grouped_data AS (SELECT location_name,
							 transaction_created_date_pst,
							 sku,
							 plain_name,
							 SUM(quantity) AS daily_quantity
					  FROM fact.netsuite_inventory_item_detail detail
					  GROUP BY location_name,
							   transaction_created_date_pst,
							   sku,
							   plain_name)
SELECT location_name,
	   transaction_created_date_pst,
	   sku,
	   plain_name,
	   SUM(daily_quantity) OVER (
		   PARTITION BY
			   sku,
			   location_name
		   ORDER BY
			   transaction_created_date_pst ROWS BETWEEN UNBOUNDED PRECEDING
			   AND CURRENT ROW
		   )   AS cumulative_quantity,
	   CASE
		   WHEN ROW_NUMBER() OVER (
			   PARTITION BY
				   sku,
				   location_name
			   ORDER BY
				   transaction_created_date_pst DESC
			   ) = 1 THEN TRUE
		   ELSE FALSE
		   END AS is_most_recent
FROM grouped_data
ORDER BY transaction_created_date_pst DESC