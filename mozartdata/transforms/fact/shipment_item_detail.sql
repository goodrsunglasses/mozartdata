SELECT
  shipment.id,
  shipment.shipmentnumber,
  shipment.custrecordgoodrponum,
  shipment.externaldocumentnumber,
  shipmentitem.id,
  shipmentitem.shipmentitemdescription,
  shipmentitem.*
FROM
  netsuite.inboundshipment shipment
  LEFT OUTER JOIN netsuite.inboundshipmentitem shipmentitem ON shipmentitem.inboundshipment = Shipment.id
WHERE
  shipmentnumber = 'INBSHIP320'