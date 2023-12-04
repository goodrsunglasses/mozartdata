SELECT
  orderline.order_id_edw,
  orderline.transaction_id_ns,
  stord.order_id stord_id,
  shipstation.orderid shipstation_id,
  d2c.id d2c_shopify_id,
  b2b.id b2b_shopify_id
FROM
  fact.order_line orderline
  LEFT OUTER JOIN stord.stord_sales_orders_8589936822 stord ON stord.order_number = orderline.order_id_edw
  LEFT OUTER JOIN shipstation_portable.shipstation_orders_8589936627 shipstation ON shipstation.ordernumber = orderline.order_id_edw
  left outer join shopify."ORDER" d2c on d2c.name = orderline.order_id_edw
  left outer join specialty_shopify."ORDER" b2b on b2b.name = orderline.order_id_edw
WHERE
  parent_transaction = TRUE
  AND order_id_edw IN ('G2140570', 'CS-LST-SD-SG-87617')