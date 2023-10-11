--note, leaving closed or otherwise odd transaction statuses as they can be later filtered out or operated on
--CS,INV,SO,IF
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  tran.recordtype,
  tran.id AS ns_id,
  transtatus.fullname AS full_status,
  tranline.item,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  SUM(- netamount) netamount,
  SUM(rate) rate,
  SUM(ABS(quantity)) AS full_quantity,
  SUM(tranline.estgrossprofit) AS estgrossprofit,
  SUM(tranline.costestimate) AS costestimate
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund'
  )
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart',
    'Payment'
  )
  AND tranline.mainline = 'F'
  AND order_id_edw IS NOT NULL
  AND (
    CASE
      WHEN recordtype IN ('invoice', 'cashsale', 'salesorder')
      AND accountinglinetype IN ('INCOME') THEN TRUE
      WHEN recordtype = 'cashrefund'
      AND accountinglinetype IN ('INCOME','PAYMENT') THEN TRUE
      WHEN recordtype = 'itemfulfillment'
      AND accountinglinetype IN ('COGS') THEN TRUE
      ELSE FALSE
    END
  )
GROUP BY
  order_id_edw,
  timestamp_transaction_pst,
  full_status,
  recordtype,
  plain_name,
  ns_id,
  item,
  detail_id
ORDER BY
  ns_id asc