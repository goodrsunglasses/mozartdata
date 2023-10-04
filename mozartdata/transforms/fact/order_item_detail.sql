SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id,
  transtatus.fullname AS full_status,
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
  AND itemtype IN ('InvtPart')
  AND mainline = 'F'
  AND accountinglinetype != 'ASSET'
  and full_status NOT LIKE '%Closed'
  AND full_status NOT LIKE '%Voided'
  AND full_status NOT LIKE '%Undefined'
  AND full_status NOT LIKE '%Rejected'
  AND full_status NOT LIKE '%Unapproved'
  AND full_status NOT LIKE '%Not Deposited'
  AND order_id_edw = 'G1863077'