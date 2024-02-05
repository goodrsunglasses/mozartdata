with net_amount as 
  (
    select
      gt.transaction_id_ns
    , gt.item_id_ns
    , sum(gt.net_amount) net_amount
    from
      fact.gl_transaction gt
    where
      gt.account_number between 4000 and 4999
    group by
      gt.transaction_id_ns
    , gt.item_id_ns
  ),
sales_tax as 
  (
    select
      gt.transaction_id_ns
    , gt.item_id_ns
    , sum(gt.net_amount) net_amount
    from
      fact.gl_transaction gt
    where
      gt.account_number between 2200.01 and 2200.99
    group by
      gt.transaction_id_ns
    , gt.item_id_ns
  )
SELECT
  REPLACE(
    COALESCE(
      tran.custbody_goodr_shopify_order,
      tran.custbody_goodr_po_number
    ),
    ' ',
    ''
  ) AS order_id_edw,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_edw, '_', tran.id, '_', item) AS order_item_detail_id,
  CASE
    WHEN tranline.itemtype IN (
      'InvtPart',
      'Assembly',
      'OthCharge',
      'NonInvtPart',
      'Payment'
    ) THEN tranline.item
  END AS product_id_edw,
  tranline.item AS item_id_ns,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
  DATE(
    CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
  ) AS transaction_created_date_pst,
  tran.recordtype AS record_type,
  transtatus.fullname AS full_status,
  tranline.itemtype AS item_type,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  na.net_amount AS net_amount,
  SUM(ABS(quantity)) AS total_quantity,
  sum(ABS(quantitybilled)) quantity_invoiced,
  sum(ABS(quantitybackordered)) quantity_backordered,
  sum(rate) as unit_rate,
  SUM(rate) * total_quantity rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  tranline.location,
  tranline.createdfrom
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN net_amount na ON na.transaction_id_ns = tran.id and na.item_id_ns = tranline.item
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund',
    'purchaseorder',
    'itemreceipt',
    'vendorbill'
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
      WHEN record_type = 'vendorbill'
      AND tranline.expenseaccount = 113 THEN TRUE --Bills dont have accountinglinetype
      WHEN recordtype = 'purchaseorder'
      AND accountinglinetype IN ('INCOME', 'ASSET') THEN TRUE
      WHEN recordtype = 'itemreceipt'
      AND accountinglinetype IN ('INCOME', 'ASSET')
      AND iscogs = 'F' THEN TRUE
      WHEN recordtype = 'cashrefund'
      AND accountinglinetype IN ('INCOME', 'PAYMENT') THEN TRUE
      WHEN recordtype = 'itemfulfillment'
      AND accountinglinetype IN ('COGS') THEN TRUE
      ELSE FALSE
    END
  )
GROUP BY
  order_id_edw,
  createdfrom,
  tran.id,
  order_item_detail_id,
  product_id_edw,
  tranline.item,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type,
  tranline.location,
  na.net_amount
  -- Shipping and Tax
UNION ALL
SELECT
    REPLACE(
    COALESCE(
      tran.custbody_goodr_shopify_order,
      tran.custbody_goodr_po_number
    ),
    ' ',
    ''
  ) AS order_id_edw,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_edw, '_', tran.id, '_', item) AS order_item_detail_id,
  CASE
    WHEN tranline.itemtype IN (
      'InvtPart',
      'Assembly',
      'OthCharge',
      'NonInvtPart',
      'Payment'
    ) THEN tranline.item
  END AS product_id_edw,
  tranline.item AS item_id_ns,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
  DATE(
    CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
  ) AS transaction_created_date_pst,
  tran.recordtype AS record_type,
  transtatus.fullname AS full_status,
  tranline.itemtype AS item_type,
  CASE
    WHEN tranline.itemtype = 'ShipItem' THEN 'Shipping'
    WHEN tranline.itemtype = 'TaxItem' THEN 'Tax'
    ELSE NULL
  END AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  st.net_amount AS net_amount,
  SUM(ABS(quantity)) AS total_quantity,
  null as quantity_invoiced,
  null as quantity_backordered,
  sum(rate) as unit_rate,
  SUM(rate) rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  NULL AS location,
  tranline.createdfrom
FROM
  netsuite.transaction tran
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
  
  LEFT OUTER JOIN netsuite.transactionstatus transtatus ON (
    tran.status = transtatus.id
    AND tran.type = transtatus.trantype
  )
  LEFT OUTER JOIN sales_tax st ON st.transaction_id_ns = tran.id and st.item_id_ns = tranline.item
  LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
WHERE
  recordtype IN (
    'invoice',
    'cashsale',
    'salesorder',
    'itemfulfillment',
    'cashrefund'
  )
  AND tranline.itemtype IN ('ShipItem', 'TaxItem')
  AND tranline.mainline = 'F'
  AND order_id_edw IS NOT NULL
GROUP BY
  order_id_edw,
  createdfrom,
  tran.id,
  order_item_detail_id,
  product_id_edw,
  tranline.item,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type,
  tranline.location,
  st.net_amount
ORDER BY
  transaction_id_ns asc