-- SELECT
--   orders.order_number,
--   orders.order_id,
--   orders.status,
--   orders.shipped_at,
--   ARRAY_AGG(shipment_confirmation_id) shipment_ids,
--   'Stord' AS source_system
-- FROM
--   stord.stord_sales_orders_8589936822 orders
--   LEFT OUTER JOIN stord.stord_shipment_confirmations_8589936822 shipments ON shipments.order_id = orders.order_id
-- WHERE
--   orders.order_number in ('SG-85790','SG-78516')
-- GROUP BY
--   orders.ordernumber,
--   orders.order_id,
--   orders.status,
--   orders.shipped_at,
--   source_system
-- UNION ALL
SELECT distinct 
  ordernumber,
  orderkey,
  orderstatus,
  shipdate,
  'Shipstation' AS source_system
FROM
  shipstation_portable.shipstation_orders_8589936627
WHERE
  ordernumber in  ('SG-CHIMAR2022','G1760109')
order by ordernumber