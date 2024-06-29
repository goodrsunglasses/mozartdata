SELECT -- the idea of this staging table is to select all the inventory affecting transactions from Netsuite to seperately replicate inventory quantities as a balance sheet rather than a snapshot
	   transaction,
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
	   tran.recordtype                                           AS record_type,
	   tran.tranid,
	   tranline.entity,
	   tranline.item,
	   COALESCE(item.displayname, item.externalid)               AS plain_name,
	   tranline.cseg7,
	   tranline.quantity,
	   tranline.itemtype,
	   tranline.dropship,
	   tranline.expenseaccount,
	   tranline.location,
	   tranline.rate,
	   tranline.rateamount,
	   tranline.inventoryreportinglocation,
	   tranline.createdfrom
FROM netsuite.transactionline tranline
		 LEFT OUTER JOIN netsuite.transaction tran ON tran.id = tranline.transaction
		 LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE ISINVENTORYAFFECTING = 'T'
  and tranline._FIVETRAN_DELETED = FALSE