CREATE OR REPLACE TABLE staging.netsuite_refund_item_detail
          COPY GRANTS as
SELECT
	   transaction as transaction_id_ns,
       tranline.id as transaction_line_id_ns,
	   REPLACE(
			   COALESCE(
					   tran.custbody_goodr_shopify_order,
					   tran.custbody_goodr_po_number
			   ),
			   ' ',
			   ''
	   )                                                         AS order_id_ns,
	   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
	   DATE(
			   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
	   )                                                         AS transaction_created_date_pst,
	date(tran.trandate) as transaction_date,
	   tran.recordtype                                           AS record_type,
	   tran.memo,
	   tranline.memo as line_memo,
	   tran.tranid as transaction_number_ns,
	   tranline.entity as customer_id_ns,
	   tranline.item as item_id_ns,
	   COALESCE(item.displayname, item.externalid)               AS plain_name,
	   tranline.cseg7 as channel_id_ns,
	   tranline.quantity,
	   tranline.itemtype,
	   tranline.expenseaccount as expense_account_id_ns,
	   tranline.rate,
	   tranline.rateamount,
	   tranline.createdfrom
FROM netsuite.transactionline tranline
		 LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
		 LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE record_type = 'cashrefund'
  AND tranline._FIVETRAN_DELETED = FALSE
