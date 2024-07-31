--CREATE OR REPLACE TABLE fact.netsuite_inventory_location
            COPY GRANTS  as
SELECT inv.sku,
	   inv.location_name,
	   inv.FIVETRAN_SNAPSHOT_DATE_PST,
	   SUM(QUANTITYAVAILABLE) total_QUANTITYAVAILABLE,
	   SUM(QUANTITYONHAND)    total_quantity_on_hand,
	   SUM(QUANTITYPICKED)    total_QUANTITYPICKED
FROM fact.NETSUITE_INVENTORY inv
GROUP BY inv.sku,
         inv.location_name,
		 inv.FIVETRAN_SNAPSHOT_DATE_PST