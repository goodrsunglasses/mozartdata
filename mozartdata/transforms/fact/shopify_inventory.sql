--CREATE OR REPLACE TABLE fact.shopify_inventory
        --    COPY GRANTS  as
SELECT --Idea here is to select from the shopify snapshot tables native to mozart then join to some relevant fact and dim tables, and also renaming to make the fields clearer
	   snapshot.store,
	   snapshot.category,
	   prod.DISPLAY_NAME,
	   snapshot.sku,
	   snapshot.quantity,
	   --From now on, as per convo converting to PST to keep things consistent across inventory system snapshots
	   CONVERT_TIMEZONE('America/Los_Angeles', snapshot.FIVETRAN_SYNC_TIME_UTC)       AS FIVETRAN_SYNC_TIME_PST,
	   DATE(CONVERT_TIMEZONE('America/Los_Angeles', snapshot.FIVETRAN_SYNC_TIME_UTC)) AS fivetran_snapshot_date_pst,
	   CONVERT_TIMEZONE('America/Los_Angeles', snapshot.UPDATED_AT_UTC)               AS UPDATED_AT_SHOPIFY_PST,
	   DATE(CONVERT_TIMEZONE('America/Los_Angeles', snapshot.UPDATED_AT_UTC))         AS UPDATED_AT_SHOPIFY_DATE_PST,
	   CONVERT_TIMEZONE('America/Los_Angeles', snapshot.snapshot_timestamp)                  AS snapshot_ts_mozart_pst,
	   snapshot.tracked,
	   --everything past here is included for posterity, as often we seem to need the most nonsensical fields for one specific request
	   snapshot.cost,
	   snapshot.ITEM_UPDATED_AT_UTC,
	   snapshot.ITEM_CREATED_AT_UTC
FROM SNAPSHOTS.STAGING__SHOPIFY_INVENTORY snapshot
		 LEFT OUTER JOIN dim.product prod ON prod.sku = snapshot.sku
WHERE tracked = TRUE
  AND store = 'Goodr.com'
  AND snapshot.sku = 'OG-HND-NRBR1'--This one from what I can tell just filters out a secondary line of False, untracked item inventory?
ORDER BY fivetran_snapshot_date_pst ASC