CREATE OR REPLACE TABLE fact.shopify_inventory
           COPY GRANTS  as
SELECT --Idea here is to select from the shopify snapshot tables native to mozart then join to some relevant fact and dim tables, and also renaming to make the fields clearer
	   snapshot.store,
	   snapshot.category,
	   prod.DISPLAY_NAME,
	   snapshot.sku,
	   snapshot.quantity,
	   --From now on, as per convo converting to PST to keep things consistent across inventory system snapshots
	   snapshot.snapshot_timestamp       AS snapshot_ts,
	   date(snapshot.snapshot_timestamp) as snapshot_date,
	   CONVERT_TIMEZONE('America/Los_Angeles', snapshot.UPDATED_AT_UTC)               AS UPDATED_AT_SHOPIFY_PST,
	   DATE(CONVERT_TIMEZONE('America/Los_Angeles', snapshot.UPDATED_AT_UTC))         AS UPDATED_AT_SHOPIFY_DATE_PST,
	   snapshot.tracked,
	   --everything past here is included for posterity, as often we seem to need the most nonsensical fields for one specific request
	   snapshot.cost,
	   snapshot.ITEM_UPDATED_AT_UTC,
	   snapshot.ITEM_CREATED_AT_UTC,
	   prod.family,
	   prod.stage,
	   prod.MERCHANDISE_CLASS,
	   prod.DESIGN_TIER,
	   CONVERT_TIMEZONE('America/Los_Angeles', snapshot.FIVETRAN_SYNC_TIME_UTC)       AS FIVETRAN_SYNC_TIME_PST,
	   DATE(CONVERT_TIMEZONE('America/Los_Angeles', snapshot.FIVETRAN_SYNC_TIME_UTC)) AS fivetran_sync_date_pst
FROM STAGING.SHOPIFY_INVENTORY_INCREMENTAL snapshot
		 LEFT OUTER JOIN dim.product prod ON prod.sku = snapshot.sku
WHERE tracked = TRUE --This one from what I can tell just filters out a secondary line of False, untracked item inventory?
ORDER BY store ASC