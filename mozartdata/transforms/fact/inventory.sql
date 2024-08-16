SELECT sku,
	   display_name,
	   FIVETRAN_SNAPSHOT_DATE_PST,
	   total_quantity_on_hand --using this one because its the highest level one available for unioning purposes
FROM fact.NETSUITE_INVENTORY_LOCATION
UNION ALL
SELECT *
FROM FROM fact.SHOPIFY_INVENTORY