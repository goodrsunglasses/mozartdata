-- CREATE OR REPLACE TABLE fact.netsuite_inventory_item_detail
-- 	COPY GRANTS AS
SELECT--the idea of this table is to link the staging inventory data to other dims and facts, like parent transactions, locations, etc... and provide a solid basis to build other facts off of
	  staging.transaction_id_ns,
	  staging.transaction_line_id_ns,
	  parents.ORDER_ID_EDW,
	  staging.RECORD_TYPE,
	  chan.name                          AS channel,
	  chan.CUSTOMER_CATEGORY,
	  chan.model,
	  staging.location_id_ns,
	  loc.name                           AS location_name,
	  staging.TRANSACTION_CREATED_TIMESTAMP_PST,
	  staging.TRANSACTION_CREATED_DATE_PST,
	  staging.tran_date,
	  staging.transaction_number_ns,
	  staging.item_id_ns,
	  staging.plain_name,
	  prod.sku,
	  staging.quantity,
	  staging.dropship,
	  staging.expense_account_id_ns,
	  staging.rate,
	  staging.rateamount,
	  staging.INVENTORYREPORTINGLOCATION AS inventory_reporting_location,
	  staging.customer_id_ns,
	  staging.createdfrom
FROM staging.INVENTORY_ITEM_DETAIL staging
		 LEFT OUTER JOIN dim.PARENT_TRANSACTIONS parents ON parents.TRANSACTION_ID_NS = staging.transaction_id_ns
		 LEFT OUTER JOIN dim.location loc ON loc.LOCATION_ID_NS = staging.location_id_ns
		 LEFT OUTER JOIN dim.product prod ON prod.ITEM_ID_NS = staging.item_id_ns
		 LEFT OUTER JOIN dim.channel chan ON chan.CHANNEL_ID_NS = staging.channel_id_ns