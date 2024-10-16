-- CREATE OR REPLACE TABLE fact.netsuite_refunds
-- 	COPY GRANTS AS
SELECT
	  staging.transaction_id_ns,
	  staging.transaction_line_id_ns,
	  parents.ORDER_ID_EDW,
	  staging.RECORD_TYPE,
	  chan.name                          AS channel,
	  chan.CUSTOMER_CATEGORY,
	  chan.model,
	  staging.TRANSACTION_CREATED_TIMESTAMP_PST,
	  staging.TRANSACTION_CREATED_DATE_PST,
	  staging.transaction_date,
	  staging.transaction_number_ns,
	  staging.item_id_ns,
	  staging.memo,
	  staging.line_memo,
	  staging.plain_name,
	  prod.sku,
	  staging.itemtype,
	  staging.quantity,
	  staging.expense_account_id_ns,
	  staging.rate,
	  staging.rateamount,
	  staging.customer_id_ns,
	  staging.createdfrom
FROM staging.netsuite_refunds staging
		 LEFT OUTER JOIN dim.PARENT_TRANSACTIONS parents ON parents.TRANSACTION_ID_NS = staging.transaction_id_ns
		 LEFT OUTER JOIN dim.product prod ON prod.ITEM_ID_NS = staging.item_id_ns
		 LEFT OUTER JOIN dim.channel chan ON chan.CHANNEL_ID_NS = staging.channel_id_ns