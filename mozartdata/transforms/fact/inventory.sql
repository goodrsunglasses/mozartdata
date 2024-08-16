SELECT sku,
	   display_name,
	   LOCATION_NAME,
	   FIVETRAN_SNAPSHOT_DATE_PST,
	   total_quantity_on_hand, --using this one because its the highest level one available for unioning purposes
'Netsuite' as source
FROM fact.NETSUITE_INVENTORY_LOCATION
UNION ALL
SELECT sku,
       display_name,
       store,
       snapshot_date,
       'Shopify' as source
FROM  fact.SHOPIFY_INVENTORY
