WITH
  sold AS (
    SELECT
      tran.custbody_goodr_shopify_order,
      tran.recordtype,
      tran.tranid,
      tranline.item,
      detail.full_status,
      tran.createddate,
      item.displayname,
      tranline.quantity,
      loc.fullname
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
      LEFT OUTER JOIN netsuite.location loc ON loc.id = tranline.location
      LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
      LEFT OUTER JOIN fact.order_item_detail detail ON (
        detail.transaction_id_ns = tran.id
        AND detail.item_id_ns = tranline.item
      )
    WHERE
      tran.createddate >= '2023-01-01T00:00:00Z'
      AND loc.fullname LIKE '%DO NOT USE%'
      AND tranline.itemtype = 'InvtPart'
      AND full_status NOT IN (
        'Invoice : Paid In Full',
        'Item Fulfillment : Shipped',
        'Cash Sale : Deposited',
        'Sales Order : Billed',
        'Sales Order : Closed'
      )
      AND tran.recordtype = 'salesorder'
  ),
  fulfilled AS (
    SELECT
      tran.custbody_goodr_shopify_order,
      tran.recordtype,
      tran.tranid,
      tranline.item,
      detail.full_status,
      tran.createddate,
      item.displayname,
      tranline.quantity,
      loc.fullname
    FROM
      netsuite.transaction tran
      LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.transaction = tran.id
      LEFT OUTER JOIN netsuite.location loc ON loc.id = tranline.location
      LEFT OUTER JOIN netsuite.item item ON item.id = tranline.item
      LEFT OUTER JOIN fact.order_item_detail detail ON (
        detail.transaction_id_ns = tran.id
        AND detail.item_id_ns = tranline.item
      )
    WHERE
      tran.createddate >= '2023-01-01T00:00:00Z'
      AND loc.fullname LIKE '%DO NOT USE%'
      AND tranline.itemtype = 'InvtPart'
      AND full_status NOT IN (
        'Invoice : Paid In Full',
        'Cash Sale : Deposited',
        'Sales Order : Billed'
      )
      AND tran.recordtype = 'itemfulfillment'
  )
SELECT DISTINCT
  sold.custbody_goodr_shopify_order ordernum,
  sold.displayname,
  sold.quantity,
  sold.tranid,
  fulfilled.tranid,
  fulfilled.quantity fulfilled_qty
FROM
  sold
  LEFT OUTER JOIN fulfilled ON (
    fulfilled.custbody_goodr_shopify_order = sold.custbody_goodr_shopify_order
    AND sold.item = fulfilled.item
  )
WHERE
  fulfilled_qty IS NULL
order by ordernum asc