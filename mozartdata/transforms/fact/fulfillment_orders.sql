SELECT
  order_number,
  order_id,
  status,
  shipped_at.
  'Stord' as source_system
FROM
  stord.stord_sales_orders_8589936822
  
UNION ALL
SELECT
  ordernumber,
  orderkey,
  orderstatus,
  shipdate,
    'Shipstation' as source_system
FROM
  shipstation_portable.shipstation_orders_8589936627