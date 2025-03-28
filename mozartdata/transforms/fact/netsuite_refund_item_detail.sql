SELECT
     concat(staging.transaction_id_ns,'_',staging.transaction_line_id_ns) AS refund_item_detail_id_edw,
     staging.transaction_id_ns,
	   staging.transaction_line_id_ns,
	   staging.order_id_ns,		
	   COALESCE(parents.ORDER_ID_EDW, staging.order_id_ns)                                          AS order_id_edw, --A bunch of amazon CR's were created via a trantype not found in dim.parent_transactions
	   staging.RECORD_TYPE,
	   chan.name                                                                                    AS channel,
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
	   CASE WHEN staging.itemtype NOT IN ('OthCharge', 'InvtPart') THEN 0 ELSE staging.quantity END AS quantity,--This is because we don't wanna count the "quantity" of tax, shipping, discounts etc...
	   staging.expense_account_id_ns,
	   staging.rate,
	   staging.rateamount,
	   staging.customer_id_ns,
	   staging.createdfrom
FROM staging.netsuite_refund_item_detail staging
		 LEFT OUTER JOIN dim.PARENT_TRANSACTIONS parents ON parents.TRANSACTION_ID_NS = staging.transaction_id_ns
		 LEFT OUTER JOIN dim.product prod ON prod.ITEM_ID_NS = staging.item_id_ns
		 LEFT OUTER JOIN dim.channel chan ON chan.CHANNEL_ID_NS = staging.channel_id_ns
