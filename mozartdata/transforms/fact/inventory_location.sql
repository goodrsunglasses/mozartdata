SELECT sku,
	   display_name,
	   LOCATION_NAME,
	   FIVETRAN_SNAPSHOT_DATE_PST as snapshot_date,
	   total_quantity_on_hand as quantity, --using this one because its the highest level one available for unioning purposes
	   'Netsuite' AS source,
       md5(concat(sku,'_',LOCATION_NAME)) as inventory_location_id
FROM fact.NETSUITE_INVENTORY_LOCATION
UNION ALL
SELECT sku,
	   display_name,
	   store as location_name,
	   snapshot_date,
	   quantity,
	   'Shopify' AS source,
       md5(concat(sku,'_',store)) as inventory_location_id
FROM fact.SHOPIFY_INVENTORY
UNION ALL
SELECT sku,
	   display_name,
	   location_name_stord,
	   snapshot_date,
	   available,
	   'Stord' AS source,
       md5(concat(sku,'_',location_name_stord)) as inventory_location_id
from fact.STORD_INVENTORY_LOCATION