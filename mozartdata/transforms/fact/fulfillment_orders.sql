WITH
  fulfillment_info AS (
    SELECT
      order_id_edw,
      ARRAY_AGG(fulfillment_id_edw) fulfillment_ids
    FROM
      dim.fulfillment
    GROUP BY
      order_id_edw
  )
SELECT DISTINCT
  orders.ordernumber order_id_edw,
  MD5(
    LISTAGG(DISTINCT orders.orderid, '_') WITHIN GROUP (
      ORDER BY
        orders.orderid
    ) over (
      PARTITION BY
        orders.ordernumber
    )
  ) AS hashed_orderid, --This was the main reason for this table, due to improper Boomi syncs, Shipstation has duplicate order_id_edws, not one row per order number on their order table, so everything coming from shipstation on an order level needs to be aggregate.
  FIRST_VALUE(orderstatus) OVER ( --Have to do this to find the first non-shipped order status, because shipping_status for SS represents an aggregate quantity, for stord its only one row per order
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
  COUNT(DISTINCT shipmentid) over (
    PARTITION BY
      orders.ordernumber
  ) shipment_count,
  ARRAY_AGG(DISTINCT orders.orderid) over (
    PARTITION BY
      orders.ordernumber
  ) order_ids,
  fulfillment_ids,
  'Shipstation' AS source_system
FROM
  shipstation_portable.shipstation_orders_8589936627 orders
  LEFT OUTER JOIN shipstation_portable.shipstation_shipments_8589936627 shipments ON shipments.ordernumber = orders.ordernumber
  LEFT OUTER JOIN fulfillment_info ON fulfillment_info.order_id_edw = orders.ordernumber
  --Union to Stord information
UNION ALL
SELECT --Stord is pretty much super straightforward
  orders.order_number order_id_edw,
  orders.order_id,
  orders.status,
  COUNT(DISTINCT shipment_confirmation_id) shipment_count,
  ARRAY_AGG(shipment_confirmation_id) shipment_ids,
  fulfillment_ids,
  'Stord' AS source_system
FROM
  stord.stord_sales_orders_8589936822 orders
  LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 shipments ON shipments.order_id = orders.order_id
  LEFT OUTER JOIN fulfillment_info ON fulfillment_info.order_id_edw = orders.order_number
GROUP BY
  fulfillment_ids,
  orders.order_number,
  orders.order_id,
  orders.status,
  source_system