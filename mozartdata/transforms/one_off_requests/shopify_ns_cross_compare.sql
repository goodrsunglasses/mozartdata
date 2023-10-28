SELECT
  orders.name,
  orders.fulfillment_status,
  orders.subtotal_price,
  tender.remote_reference,
  tran.tranid
FROM
  shopify."ORDER" orders
  LEFT OUTER JOIN netsuite.transaction tran ON tran.custbody_goodr_shopify_order = orders.name
  left outer join shopify.tender_transaction tender on tender.order_id = orders.id
WHERE
  tranid IS NULL
  AND orders.created_at >= '2023-01-01T00:00:00Z'
  AND fulfillment_status = 'fulfilled'
  AND subtotal_price > 0