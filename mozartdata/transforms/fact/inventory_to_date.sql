WITH running_totals AS (SELECT location_name,
							   transaction_created_date_pst,
							   sku,
							   plain_name,
							   SUM(quantity) OVER (
								   PARTITION BY
									   sku,
									   location_name,
									   plain_name
								   ORDER BY
									   transaction_created_date_pst ROWS BETWEEN UNBOUNDED PRECEDING
									   AND CURRENT ROW
								   )                                                                           AS cumulative_quantity,
							   ROW_NUMBER() OVER (PARTITION BY sku ORDER BY transaction_created_date_pst DESC) AS row_num
						FROM fact.inventory_item_detail)
SELECT location_name,
	   transaction_created_date_pst,
	   sku,
	   plain_name,
	   cumulative_quantity,
	   CASE
		   WHEN row_num = 1 THEN TRUE
		   ELSE FALSE
		   END AS is_most_recent
FROM running_totals
ORDER BY location_name, transaction_created_date_pst