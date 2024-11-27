/*
Purpose: To show each line item of each fulfillment. One row per line id per fulfillment id.

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

SELECT -- the idea of this staging table is to select all the inventory affecting transactions from Netsuite to seperately replicate inventory quantities as a balance sheet rather than a snapshot
	   --As per what I (KSL) usually do for these I am kinda just broad swathe selecting columns that I think will be useful to be save
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
	   tran.tranid as transaction_number_ns,
	   tranline.entity as customer_id_ns,
	   tranline.item as item_id_ns,
	   COALESCE(item.displayname, item.externalid)               AS plain_name,
	   tranline.cseg7 as channel_id_ns,
	   tranline.quantity,
	   tranline.itemtype,
	   tranline.dropship,
	   tranline.expenseaccount as expense_account_id_ns,
	   tranline.location as location_id_ns,
	   tranline.rate,
	   tranline.rateamount,
	   tranline.inventoryreportinglocation,
	   tranline.createdfrom
FROM netsuite.transactionline tranline
		 LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
		 LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE ISINVENTORYAFFECTING = 'T'
  AND tranline._FIVETRAN_DELETED = FALSE