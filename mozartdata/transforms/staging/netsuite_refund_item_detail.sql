/*
Purpose: show refund information for each item as entered in Netsuite.
One row per transaction, which translates to one row per item per refund.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
SELECT transaction                                               AS transaction_id_ns,
	   tranline.id                                               AS transaction_line_id_ns,
	   REPLACE(
			   COALESCE(
					   tran.custbody_goodr_shopify_order,
					   tran.custbody_goodr_po_number,
					   CASE WHEN tranline.CREATEDFROM IS NULL THEN tran.tranid end-- added this in for all the one off ASC refunds with no order number or parents
			   ),
			   ' ',
			   ''
	   )                                                         AS order_id_ns,
	   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
	   DATE(
			   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
	   )                                                         AS transaction_created_date_pst,
	   DATE(tran.trandate)                                       AS transaction_date,
	   tran.recordtype                                           AS record_type,
	   tran.memo,
	   tranline.memo                                             AS line_memo,
	   tran.tranid                                               AS transaction_number_ns,
	   tranline.entity                                           AS customer_id_ns,
	   tranline.item                                             AS item_id_ns,
	   COALESCE(item.displayname, item.externalid)               AS plain_name,
	   tranline.cseg7                                            AS channel_id_ns,
	   tranline.quantity,
	   tranline.itemtype,
	   tranline.expenseaccount                                   AS expense_account_id_ns,
	   tranline.rate,
	   tranline.rateamount,
	   tranline.createdfrom
FROM netsuite.transactionline tranline
		 LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
		 LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE record_type = 'cashrefund'
  AND tranline._FIVETRAN_DELETED = FALSE