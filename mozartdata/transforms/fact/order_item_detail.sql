--note, leaving closed or otherwise odd transaction statuses as they can be later filtered out or operated on
SELECT
  tran.custbody_goodr_shopify_order AS order_id_edw,
  tran.recordtype,
  tran.id as ns_id,
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
  md5(concat(order_id_edw,tran.id,item)) as detail_id
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
    'ShipItem',
    'TaxItem'
  )
  AND tranline.mainline = 'F'
  AND (
    accountinglinetype != 'ASSET'
    OR accountinglinetype IS NULL
  )
  and custcol1 is null --added as some IF's had null accountinglinetype items on them, and for some reason they also seem to have this column filled in, whereas the ASSET or COGS ones don't.
  and custcolcustom_shopify_line_item_id is null --same as above
  and donotdisplayline != true
ORDER BY
  order_id_edw,
  recordtype asc