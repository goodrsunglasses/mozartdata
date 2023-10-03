--Shipstation Shipment Creations
SELECT
  shipments.ordernumber AS order_num,
  shipments.shipmentid,
  shipments.createdate,
  shipmentitems[0]:QUANTITY::INTEGER AS quantity_listed,
  'Shipment Created' AS event_type,
  -- status_flag_edw,
  shipments.voided AS void_flag
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments
  left outer join shipstation_portable.shipstation_shipment_items_8589936627 ship_item on ship_item.ordernumber = shipments.ordernumber
  
WHERE
  shipments.createdate >= '2022-01-01T00:00:00Z'
  AND order_num = 'G1863077'
ORDER BY
  event_type desc