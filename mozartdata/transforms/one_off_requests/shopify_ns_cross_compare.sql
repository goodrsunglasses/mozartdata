SELECT
  orders.name,
  orders.fulfillment_status,
  orders.subtotal_price,
  tran.tranid
FROM
  shopify."ORDER" orders 
  left outer join netsuite.transaction tran on tran.custbody_goodr_shopify_order = orders.name
  
WHERE
tranid is null
and orders.created_at >= '2023-01-01T00:00:00Z'
and fulfillment_status = 'fulfilled'
and subtotal_price >0