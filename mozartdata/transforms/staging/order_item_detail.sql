-- CREATE OR REPLACE TABLE staging.order_item_detail
--             COPY GRANTS  as
WITH orphan_transactions as
(
  SELECT distinct
    tran.id as transaction_id_ns
  , tranline.createdfrom
  , REPLACE(
    COALESCE(
      tran.custbody_goodr_shopify_order,
      tran.custbody_goodr_po_number
    ),
    ' ',
    ''
  ) AS order_id_ns
  FROM
    NETSUITE.TRANSACTION tran
  LEFT JOIN
    NETSUITE.TRANSACTIONLINE tranline
    ON tran.id = tranline.transaction
  WHERE
    order_id_ns is null
    and tranline.CREATEDFROM is not null
)
, parent_order_ids as
(
  SELECT
    ot.transaction_id_ns
  , parent.id as parent_transaction_id_ns
  , parent.recordtype as parent_record_type
,   REPLACE(
      COALESCE(
        parent.custbody_goodr_shopify_order,
        parent.custbody_goodr_po_number
      ),
      ' ',
    ''
  ) AS order_id_ns
  FROM
    orphan_transactions ot
  LEFT JOIN
    NETSUITE.TRANSACTION parent
    ON ot.CREATEDFROM = parent.id
)
, all_transactions as
(
  SELECT
    COALESCE(poi.order_id_ns,REPLACE(
      COALESCE(
        tran.custbody_goodr_shopify_order,
        tran.custbody_goodr_po_number
      ),
      ' ',
    '')) as order_id_ns
  , tran.*
  FROM
    NETSUITE.TRANSACTION tran
  LEFT JOIN
    parent_order_ids poi
    ON tran.id = poi.transaction_id_ns

)
SELECT
  tran.order_id_ns,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_ns, '_', tran.id, '_', item) AS order_item_detail_id,
  CASE
    WHEN tranline.itemtype IN (
      'InvtPart',
      'Assembly',
      'OthCharge',
      'NonInvtPart',
      'Payment',
      'Discount'
    ) THEN tranline.item
  END AS product_id_edw,
  tranline.item AS item_id_ns,
  date(tran.trandate) as transaction_date,
  CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate) AS transaction_created_timestamp_pst,
  DATE(
    CONVERT_TIMEZONE('America/Los_Angeles', tran.createddate)
  ) AS transaction_created_date_pst,
  tran.recordtype AS record_type,
  transtatus.fullname AS full_status,
  tranline.itemtype AS item_type,
  COALESCE(item.displayname, item.externalid) AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  null AS net_amount, --moved this to fact.order_item_detail
  SUM(ABS(quantity)) AS total_quantity,
  SUM(ABS(quantitybilled)) quantity_invoiced,
  SUM(ABS(quantitybackordered)) quantity_backordered,
  SUM(rate) AS unit_rate,
  SUM(rate) * total_quantity rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  tranline.location,
  tranline.createdfrom,
  tran.SHIPPINGADDRESS,
  tran.custbodywarranty_reference as warranty_order_id_ns,
  tran.entity as customer_id_ns,
  tran.cseg7 as channel_id_ns,
  tranline.ratepercent as rate_percent
FROM
  all_transactions tran
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
    'cashrefund',
    'purchaseorder',
    'itemreceipt',
    'vendorbill',
    'estimate'
  )
  AND tranline.itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart',
    'Payment'
  )
  AND tranline.mainline = 'F'
  AND order_id_ns IS NOT NULL
  AND (
    CASE
      WHEN recordtype IN ('invoice', 'cashsale', 'salesorder', 'estimate')
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
  AND (tran._FIVETRAN_DELETED = false or tran._FIVETRAN_DELETED is null)
  AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
  )
GROUP BY
  order_id_ns,
  createdfrom,
  tran.id,
  order_item_detail_id,
  product_id_edw,
  tranline.item,
  transaction_date,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type,
  tranline.location,
  tran.SHIPPINGADDRESS,
  tran.custbodywarranty_reference,
  tran.entity,
  tran.cseg7,
  rate_percent
  -- Shipping and Tax and Discount
UNION ALL
SELECT
  tran.order_id_ns,
  tran.id AS transaction_id_ns,
  CONCAT(order_id_ns, '_', tran.id, '_', item) AS order_item_detail_id,
  CASE
    WHEN tranline.itemtype IN (
      'InvtPart',
      'Assembly',
      'OthCharge',
      'NonInvtPart',
      'Payment',
      'Discount'
    ) THEN tranline.item
  END AS product_id_edw,
  tranline.item AS item_id_ns,
  date(tran.trandate) as transaction_date,
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
    WHEN tranline.itemtype = 'Discount' THEN 'Discount'
    ELSE NULL
  END AS plain_name, --mostly used for QC purposes, easily being able to see whats going on in the line
  null as net_amount, --moved this to fact.order_item_detail
  SUM(ABS(quantity)) AS total_quantity,
  NULL AS quantity_invoiced,
  NULL AS quantity_backordered,
  SUM(rate) AS unit_rate,
  SUM(rate) rate,
  SUM(tranline.estgrossprofit) AS gross_profit_estimate,
  SUM(tranline.costestimate) AS cost_estimate,
  NULL AS location,
  tranline.createdfrom,
  tran.SHIPPINGADDRESS,
  tran.custbodywarranty_reference as warranty_order_id_ns,
  tran.entity as customer_id_ns,
  tran.cseg7 as channel_id_ns,
  tranline.RATEPERCENT as rate_percent
FROM
  all_transactions tran
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
  AND tranline.itemtype IN ('ShipItem', 'TaxItem','Discount')
  AND tranline.mainline = 'F'
  AND order_id_ns IS NOT NULL
  AND tran._FIVETRAN_DELETED = false
  AND tranline._FIVETRAN_DELETED = false
GROUP BY
  order_id_ns,
  createdfrom,
  tran.id,
  order_item_detail_id,
  product_id_edw,
  tranline.item,
  transaction_date,
  transaction_created_timestamp_pst,
  transaction_created_date_pst,
  record_type,
  full_status,
  plain_name,
  item_type,
  tranline.location,
  tran.SHIPPINGADDRESS,
  tran.custbodywarranty_reference,
  tran.entity,
  tran.cseg7,
  rate_percent
ORDER BY
  transaction_id_ns asc

