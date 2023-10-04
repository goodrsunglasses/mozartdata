SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id,
  transtatus.fullname as status,
  item,
  itemtype,
  CASE
    WHEN quantity < 0 THEN - quantity
    ELSE quantity
  END AS quantity,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_PST
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
WHERE
  recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund'
  )
  and status not like '' 
  AND itemtype IN ('InvtPart')
  AND mainline = 'F'
  AND accountinglinetype != 'ASSET'
  AND order_id_edw = 'G1863077'