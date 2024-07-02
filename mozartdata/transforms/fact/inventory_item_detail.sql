CREATE OR REPLACE TABLE fact.inventory_item_detail
            COPY GRANTS  as
SELECT--the idea of this table is to link the staging inventory data to other dims and facts, like parent transactions, locations, etc... and provide a solid basis to build other facts off of
	  staging.transaction AS transaction_id_ns,
	  parents.ORDER_ID_EDW,
	    staging.RECORD_TYPE,
	  chan.name as channel,
	  chan.CUSTOMER_CATEGORY,
	  chan.model,
	  staging.location as location_id_ns,
	  loc.name as location_name,
	  staging.TRANSACTION_CREATED_TIMESTAMP_PST,
	  staging.TRANSACTION_CREATED_DATE_PST,
	  staging.tranid,
	  staging.item as item_id_ns,
	  staging.plain_name,
	  prod.sku,
	  staging.quantity,
	  staging.dropship,
	  staging.EXPENSEACCOUNT,
	  staging.rate,
	  staging.rateamount,
	  staging.INVENTORYREPORTINGLOCATION,
	  staging.entity,
	  staging.createdfrom
FROM staging.INVENTORY_ITEM_DETAIL staging
		 LEFT OUTER JOIN dim.PARENT_TRANSACTIONS parents ON parents.TRANSACTION_ID_NS = staging.transaction
		 LEFT OUTER JOIN dim.location loc ON loc.LOCATION_ID_NS = staging.location
		 LEFT OUTER JOIN dim.product prod ON prod.ITEM_ID_NS = staging.item
		 LEFT OUTER JOIN dim.channel chan ON chan.CHANNEL_ID_NS = staging.cseg7