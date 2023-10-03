--Idea for this is to replicate the logic we already have in place for SS->NS that makes it so that we'll have one shipment per row, 
SELECT
  shipments.ordernumber AS order_num,
  shipments.shipmentid,
  shipments.servicecode,
  shipments.shipmentcost,
  shipments.createdate,
  shipmentitems[0]:QUANTITY::INTEGER AS quantity_listed,
  sum( case when )
  shipments.voided AS void_flag
FROM
  shipstation_portable.shipstation_shipments_8589936627 shipments
  LEFT OUTER JOIN shipstation_portable.shipstation_shipment_items_8589936627 ship_item ON ship_item.shipmentid = shipments.shipmentid
  left outer join netsuite.transaction tran on tran.custbody_shipment_id = shipments.shipmentid
  left outer join netsuite.transactionline tranline on tranline.transction=tran.id
WHERE
  shipments.createdate >= '2022-01-01T00:00:00Z'
  AND order_num = 'G1863077'
ORDER BY
  event_type desc