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
								   ) AS cumulative_quantity
						FROM fact.inventory_item_detail)
SELECT *
FROM running_totals order by location_name,transaction_created_date_pst