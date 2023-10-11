--note, leaving closed or otherwise odd transaction statuses as they can be later filtered out or operated on
--CS,INV,SO
-- SELECT
--   tran.custbody_goodr_shopify_order AS order_id_edw,
--   MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id,
--   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
--   tran.recordtype,
--   tran.id AS ns_id,
--   transtatus.fullname AS full_status,
--   tranline.item,
--   COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
--   SUM(- netamount) netamount,
--   SUM(rate) rate,
--   SUM(abs(quantity)) AS full_quantity,
--   SUM(tranline.estgrossprofit) AS estgrossprofit,
--   SUM(tranline.costestimate) AS costestimate
-- FROM
--   netsuite.transaction tran
--   LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
--   LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
--     tran.status = transtatus.id
--     AND tran.type = transtatus.trantype
--   )
--   LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
-- WHERE
--   recordtype IN (
--     'invoice',
--     'cashsale',
--     'salesorder',
--     'itemfulfillment'
--   )
--   AND tranline.itemtype IN (
--     'InvtPart',
--     'Assembly',
--     'OthCharge',
--     'NonInvtPart'
--   )
--   AND tranline.mainline = 'F'
--   AND accountinglinetype IN ('INCOME', 'COGS')
-- GROUP BY
--   order_id_edw,
--   timestamp_transaction_pst,
--   full_status,
--   recordtype,
--   plain_name,
--   ns_id,
--   item,
--   detail_id
-- ORDER BY
--   ns_id asc
SELECT distinct
  tran.custbody_goodr_shopify_order AS order_id_edw,
  MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  tran.recordtype,
  tran.id AS ns_id,
  transtatus.fullname AS full_status,
  tranline.item,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  SUM(- netamount) over (
    PARTITION BY
      ns_id,
      item,
      order_id_edw
  ) netamount,
  SUM(rate) over (
    PARTITION BY
      ns_id,
      item,
      order_id_edw
  ) rate,
  SUM(ABS(quantity)) over (
    PARTITION BY
      ns_id,
      item,
      order_id_edw
  ) AS full_quantity,
  SUM(tranline.estgrossprofit) over (
    PARTITION BY
      ns_id,
      item,
      order_id_edw
  ) AS estgrossprofit,
  SUM(tranline.costestimate) over (
    PARTITION BY
      ns_id,
      item,
      order_id_edw
  ) AS costestimate
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
    'itemfulfillment'
  )
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart'
  )
  AND tranline.mainline = 'F'
  AND (
    CASE
      WHEN recordtype != 'itemfulfillment'
      AND accountinglinetype IN ('INCOME') THEN TRUE
      WHEN recordtype = 'itemfulfillment'
      AND accountinglinetype IN ('COGS') THEN TRUE
      ELSE FALSE
    END
  )
  --IF
  -- UNION ALL
  -- SELECT
  --   tran.custbody_goodr_shopify_order AS order_id_edw,
  --   MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id,
  --   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  --   tran.recordtype,
  --   tran.id AS ns_id,
  --   transtatus.fullname AS full_status,
  --   tranline.item,
  --   COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  --   SUM(- netamount) netamount,
  --   SUM(rate) rate,
  --   SUM(quantity) AS full_quantity,
  --   SUM(tranline.estgrossprofit) AS estgrossprofit,
  --   SUM(tranline.costestimate) AS costestimate
  -- FROM
  --   netsuite.transaction tran
  --   LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  --   LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
  --     tran.status = transtatus.id
  --     AND tran.type = transtatus.trantype
  --   )
  --   LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
  -- WHERE
  --   recordtype = 'itemfulfillment'
  --   AND tranline.itemtype IN (
  --     'InvtPart',
  --     'Assembly',
  --     'OthCharge',
  --     'NonInvtPart'
  --   )
  --   AND tranline.mainline = 'F'
  --   AND accountinglinetype = 'COGS'
  -- GROUP BY
  --   order_id_edw,
  --   timestamp_transaction_pst,
  --   full_status,
  --   recordtype,
  --   plain_name,
  --   ns_id,
  --   item,
  --   detail_id
  --   --CR
  -- UNION ALL
  -- SELECT
  --   tran.custbody_goodr_shopify_order AS order_id_edw,
  --   tran.recordtype,
  --   tran.id AS ns_id,
  --   transtatus.fullname AS full_status,
  --   tranline.item,
  --   COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  --   CASE
  --     WHEN quantity < 0 THEN - quantity
  --     ELSE quantity
  --   END AS full_quantity,
  --   tranline.rate * full_quantity product_rate, --multiplied by -1 to just show financial values positively
  --   - tranline.netamount AS netamount,
  --   tranline.estgrossprofit,
  --   - tranline.costestimate AS costestimate, --multiplied by -1 to just show financial values positively
  --   CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS timestamp_transaction_pst,
  --   MD5(CONCAT(order_id_edw, tran.id, item)) AS detail_id
  -- FROM
  --   netsuite.transaction tran
  --   LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  --   LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
  --     tran.status = transtatus.id
  --     AND tran.type = transtatus.trantype
  --   )
  --   LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
  -- WHERE
  --   recordtype = 'cashrefund'
  --   AND tranline.itemtype IN (
  --     'InvtPart',
  --     'Assembly',
  --     'OthCharge',
  --     'NonInvtPart'
  --   )
  --   AND tranline.mainline = 'F'
  --   AND accountinglinetype != 'ASSET'
  --   -- AND custcol1 IS NULL --added as some IF's had null accountinglinetype items on them, and for some reason they also seem to have this column filled in, whereas the ASSET or COGS ones don't.
  --   -- AND custcolcustom_shopify_line_item_id IS NULL --same as above
  --   AND donotdisplayline != 'T'