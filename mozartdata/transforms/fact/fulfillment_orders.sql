SELECT
  orders.ordernumber order_id_edw,
  MD5(
    LISTAGG(orders.orderid, '_') WITHIN GROUP (
      ORDER BY
        orders.orderid
    )
  ) AS hashed_orderid,
  FIRST_VALUE(orderstatus) OVER ( --Have to do this to find the first non-shipped order status, because shipping_status for SS represents an aggregate quantity
    PARTITION BY
      orders.ordernumber
    ORDER BY
      CASE
        WHEN orderstatus = 'cancelled' THEN 1
        WHEN orderstatus = 'awaiting_shipment' THEN 2
        WHEN orderstatus = 'shipped' THEN 3
        ELSE 4
      END
  ) AS shipping_status,
  COUNT(DISTINCT shipmentid) shipment_count,
  ARRAY_AGG(orders.orderid) order_ids,
  'Shipstation' AS source_system
FROM
  shipstation_portable.shipstation_orders_8589936627 orders
  LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 shipments ON shipments.ordernumber = orders.ordernumber
GROUP BY
  orders.ordernumber,
  orders.orderstatus
UNION ALL
SELECT
  orders.order_number order_id_edw,
  orders.order_id,
  orders.status,
  COUNT(DISTINCT shipment_confirmation_id) shipment_count,
  ARRAY_AGG(shipment_confirmation_id) shipment_ids,
  'Stord' AS source_system
FROM
  stord.stord_sales_orders_8589936822 orders
  LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 shipments ON shipments.order_id = orders.order_id
GROUP BY
  order_id_edw,
  orders.order_id,
  orders.status,
  source_system