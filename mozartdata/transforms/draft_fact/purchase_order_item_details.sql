--note, leaving closed or otherwise odd transaction statuses as they can be later filtered out or operated on
--CS,INV,SO,IF
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_edw,'_', tran.id,'_', item) AS order_item_detail_id,
  tranline.item as item_id_ns,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_timestamp_pst,
  date(CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)) AS transaction_date_pst,
  tran.recordtype as record_type,
  transtatus.fullname AS full_status,
  tranline.itemtype as item_type,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  SUM(- netamount) as net_amount,
  SUM(ABS(quantity)) AS total_quantity,
  SUM(rate)*total_quantity rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  tranline.location
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
    'purchaseorder'
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
      AND accountinglinetype IN ('INCOME', 'PAYMENT') THEN TRUE
      WHEN recordtype = 'itemfulfillment'
      AND accountinglinetype IN ('COGS') THEN TRUE
      ELSE FALSE
    END
  )
GROUP BY
  order_id_edw,
  transaction_id_ns,
  order_item_detail_id,
  item_id_ns,
  transaction_timestamp_pst,
  transaction_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type,
  tranline.location
  
  --Shipping and Tax
UNION ALL
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_edw,'_', tran.id,'_', item) AS order_item_detail_id,
  tranline.item as item_id_ns,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_timestamp_pst,
  date(CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)) AS transaction_date_pst,
  tran.recordtype as record_type,
  transtatus.fullname AS full_status,
  tranline.itemtype as item_type,
  CASE
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    ELSE NULL
  END AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  SUM(- netamount) net_amount,
  SUM(ABS(quantity)) AS total_quantity,
  SUM(rate) rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  null as location
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
    'purchaseorder'
  )
  AND tranline.itemtype IN ('ShipItem', 'TaxItem')
  AND tranline.mainline = 'F'
  AND order_id_edw IS NOT NULL
GROUP BY
  order_id_edw,
  transaction_id_ns,
  order_item_detail_id,
  item_id_ns,
  transaction_timestamp_pst,
  transaction_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type

ORDER BY
  transaction_id_ns asc