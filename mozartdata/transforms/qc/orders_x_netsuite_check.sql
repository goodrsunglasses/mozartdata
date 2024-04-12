SELECT
  tran.id,
  tranid,
  tran.recordtype,
  tran.createddate,
  tran.custbody_goodr_shopify_order,
  tran.custbody_goodr_po_number,
  netamount,
  order_id_ns
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN staging.order_item_detail detail ON tran.id = detail.transaction_id_ns
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
WHERE
  tranline.id = 0
  AND order_id_ns IS NULL
  AND netamount IS NOT NULL
  AND tran.recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund',
    'purchaseorder',
    'itemreceipt',
    'vendorbill',
    'estimate'
  )
ORDER BY
  createddate desc