SELECT
  shipment.id shipment_id_ns,
  shipment.shipmentnumber,
  shipmentitem.shipmentitemdescription,
  tranline.item,
  shipmentitem.expectedrate,
  shipmentitem.quantitybilled,
  quantityexpected,
  quantityreceived,
  quantityremaining,
  receivinglocation,
  shipmentitemamount,
  totalunitcost,
  unitlandedcost,
  purchaseordertransaction,
  shipmentitemtransaction
FROM
  netsuite.inboundshipment shipment
  LEFT OUTER JOIN netsuite.inboundshipmentitem shipmentitem ON shipmentitem.inboundshipment = Shipment.id
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.uniquekey = shipmentitem.shipmentitemtransaction