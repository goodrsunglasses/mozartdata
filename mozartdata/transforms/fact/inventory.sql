-- CREATE OR REPLACE TABLE fact.inventory
--             COPY GRANTS  as
SELECT sku,
	   display_name,
	   LOCATION_NAME,
	   FIVETRAN_SNAPSHOT_DATE_PST as snapshot_date,
	   total_quantity_on_hand, --using this one because its the highest level one available for unioning purposes
	   'Netsuite' AS source
FROM fact.NETSUITE_INVENTORY_LOCATION
UNION ALL
SELECT sku,
	   display_name,
	   store,
	   snapshot_date,
	   quantity,
	   'Shopify' AS source
FROM fact.SHOPIFY_INVENTORY
UNION ALL
SELECT sku,
	   display_name,
	   location_name_stord,
	   snapshot_date,
	   available,
	   'Stord' AS source
from fact.STORD_INVENTORY_LOCATION