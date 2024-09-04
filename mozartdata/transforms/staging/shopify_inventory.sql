--The main idea here is to just grab as much raw inventory data as possible from the various shopify connectors we have to have it nicely staged and the columns renamed
SELECT 'Goodr.com'     AS     store,
	   'D2C'           AS     category,
	   level._fivetran_synced fivetran_sync_time_utc, --Added utc to this and the other ones in an effort to make it simpler to convert them downstream
	   level.updated_at       updated_at_utc,
	   level.inventory_item_id,
	   item.sku,
	   item.created_at        item_created_at_utc,
	   item.updated_at        item_updated_at_utc,
	   item.cost,
	   item.tracked,
	   level.available AS     quantity
FROM shopify.INVENTORY_LEVEL level
		 LEFT OUTER JOIN shopify.INVENTORY_ITEM item ON item.id = level.INVENTORY_ITEM_ID
WHERE item._FIVETRAN_DELETED = FALSE
UNION ALL
SELECT 'Specialty'     AS     store,
	   'B2B'           AS     category,
	   level._fivetran_synced fivetran_sync_time_utc, --Added utc to this and the other ones in an effort to make it simpler to convert them downstream
	   level.updated_at       updated_at_utc,
	   level.inventory_item_id,
	   item.sku,
	   item.created_at        item_created_at_utc,
	   item.updated_at        item_updated_at_utc,
	   item.cost,
	   item.tracked,
	   level.available AS     quantity
FROM SPECIALTY_SHOPIFY.INVENTORY_LEVEL level
		 LEFT OUTER JOIN SPECIALTY_SHOPIFY.INVENTORY_ITEM item ON item.id = level.INVENTORY_ITEM_ID
WHERE item._FIVETRAN_DELETED = FALSE
UNION ALL
SELECT 'Goodrwill'     AS     store,
	   'Indirect'      AS     category,
	   level._fivetran_synced fivetran_sync_time_utc, --Added utc to this and the other ones in an effort to make it simpler to convert them downstream
	   level.updated_at       updated_at_utc,
	   level.inventory_item_id,
	   item.sku,
	   item.created_at        item_created_at_utc,
	   item.updated_at        item_updated_at_utc,
	   item.cost,
	   item.tracked,
	   level.available AS     quantity
FROM GOODRWILL_SHOPIFY.INVENTORY_LEVEL level
		 LEFT OUTER JOIN GOODRWILL_SHOPIFY.INVENTORY_ITEM item ON item.id = level.INVENTORY_ITEM_ID
WHERE item._FIVETRAN_DELETED = FALSE
UNION ALL
SELECT 'Goodr.ca'     AS     store,
       'D2C'      AS     category,
	   level._fivetran_synced fivetran_sync_time_utc, --Added utc to this and the other ones in an effort to make it simpler to convert them downstream
	   level.updated_at       updated_at_utc,
	   level.inventory_item_id,
	   item.sku,
	   item.created_at        item_created_at_utc,
	   item.updated_at        item_updated_at_utc,
	   item.cost,
	   item.tracked,
	   level.available AS     quantity
FROM GOODR_CANADA_SHOPIFY.INVENTORY_LEVEL level
		 LEFT OUTER JOIN GOODR_CANADA_SHOPIFY.INVENTORY_ITEM item ON item.id = level.INVENTORY_ITEM_ID
WHERE item._FIVETRAN_DELETED = FALSE
UNION ALL
SELECT 'Specialty CAN'       AS     store,
       'B2B'      AS     category,
	   level._fivetran_synced fivetran_sync_time_utc, --Added utc to this and the other ones in an effort to make it simpler to convert them downstream
	   level.updated_at       updated_at_utc,
	   level.inventory_item_id,
	   item.sku,
	   item.created_at        item_created_at_utc,
	   item.updated_at        item_updated_at_utc,
	   item.cost,
	   item.tracked,
	   level.available AS     quantity
FROM SELLGOODR_CANADA_SHOPIFY.INVENTORY_LEVEL level
		 LEFT OUTER JOIN SELLGOODR_CANADA_SHOPIFY.INVENTORY_ITEM item ON item.id = level.INVENTORY_ITEM_ID
WHERE item._FIVETRAN_DELETED = FALSE