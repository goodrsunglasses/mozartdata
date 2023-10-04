SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id,
  transtatus.fullname AS full_status,
  tranline.item,
  CASE
    WHEN quantity < 0 THEN - quantity
    ELSE quantity
  END AS full_quantity,
  tranline.rate *full_quantity product_rate,--multiplied by -1 to just show financial values positively
  -tranline.netamount AS netamount,
  tranline.estgrossprofit,
  -tranline.costestimate as costestimate,--multiplied by -1 to just show financial values positively
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
  AND itemtype IN ('InvtPart', 'ShipItem')
  AND mainline = 'F'
  AND accountinglinetype != 'ASSET'
  AND full_status NOT LIKE '%Closed'
  AND full_status NOT LIKE '%Voided'
  AND full_status NOT LIKE '%Undefined'
  AND full_status NOT LIKE '%Rejected'
  AND full_status NOT LIKE '%Unapproved'
  AND full_status NOT LIKE '%Not Deposited'
  AND order_id_edw = 'G1863077'