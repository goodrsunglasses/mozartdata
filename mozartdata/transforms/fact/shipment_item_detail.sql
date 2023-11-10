SELECT
  shipment.id,
  shipment.shipmentnumber,
  shipment.custrecordgoodrponum,
  shipment.externaldocumentnumber,
  shipmentitem.id,
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
  shipmentitemtransaction,
  vendorid
FROM
  netsuite.inboundshipment shipment
  LEFT OUTER JOIN netsuite.inboundshipmentitem shipmentitem ON shipmentitem.inboundshipment = Shipment.id
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.uniquekey = shipmentitem.shipmentitemtransaction
WHERE
  shipmentnumber = 'INBSHIP320'