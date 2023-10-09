--note, leaving closed or otherwise odd transaction statuses as they can be later filtered out or operated on
--CS,INV,SO
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id AS ns_id,
  transtatus.fullname AS full_status,
  tranline.item,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  CASE
    WHEN quantity < 0 THEN - quantity
    ELSE quantity
  END AS full_quantity,
  tranline.rate * full_quantity product_rate, --multiplied by -1 to just show financial values positively
  - tranline.netamount AS netamount,
  tranline.estgrossprofit,
  - tranline.costestimate AS costestimate, --multiplied by -1 to just show financial values positively
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype IN ('invoice', 'cashsale', 'salesorder')
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart'
  )
  AND tranline.mainline = 'F'
  AND accountinglinetype != 'ASSET'
  -- AND custcol1 IS NULL --added as some IF's had null accountinglinetype items on them, and for some reason they also seem to have this column filled in, whereas the ASSET or COGS ones don't.
  -- AND custcolcustom_shopify_line_item_id IS NULL --same as above
  AND donotdisplayline != 'T'
  --IF
UNION ALL
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id AS ns_id,
  transtatus.fullname AS full_status,
  tranline.item,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  CASE
    WHEN quantity < 0 THEN - quantity
    ELSE quantity
  END AS full_quantity,
  tranline.rate * full_quantity product_rate, --multiplied by -1 to just show financial values positively
  - tranline.netamount AS netamount,
  tranline.estgrossprofit,
  - tranline.costestimate AS costestimate, --multiplied by -1 to just show financial values positively
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype = 'itemfulfillment'
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart'
  )
  AND tranline.mainline = 'F'
  AND accountinglinetype != 'ASSET'
  -- AND custcol1 IS NULL --added as some IF's had null accountinglinetype items on them, and for some reason they also seem to have this column filled in, whereas the ASSET or COGS ones don't.
  -- AND custcolcustom_shopify_line_item_id IS NULL --same as above
  AND donotdisplayline != 'T'
  --CR
UNION ALL
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id AS ns_id,
  transtatus.fullname AS full_status,
  tranline.item,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  CASE
    WHEN quantity < 0 THEN - quantity
    ELSE quantity
  END AS full_quantity,
  tranline.rate * full_quantity product_rate, --multiplied by -1 to just show financial values positively
  - tranline.netamount AS netamount,
  tranline.estgrossprofit,
  - tranline.costestimate AS costestimate, --multiplied by -1 to just show financial values positively
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype = 'cashrefund'
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart'
  )
  AND tranline.mainline = 'F'
  AND accountinglinetype != 'ASSET'
  -- AND custcol1 IS NULL --added as some IF's had null accountinglinetype items on them, and for some reason they also seem to have this column filled in, whereas the ASSET or COGS ones don't.
  -- AND custcolcustom_shopify_line_item_id IS NULL --same as above
  AND donotdisplayline != 'T'