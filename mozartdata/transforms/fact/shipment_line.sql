SELECT
  shipment.id shipment_id_ns,
  shipmentstatus,
  shipmentnumber,
  shipmenttype.name,
  custrecordcustrecord_actual_delivery_,
  custrecordcustrecord_actual_ex_factory,
  custrecordcustrecord_ata_to_destination,
  custrecordcustrecord_atd_from_origin,
  custrecordcustrecord_eta_to_destination,
  custrecordcustrecord_etd_from_origin,
  custrecordcustrecord_planned_delivery,
  custrecordgoodrponum,
  externaldocumentnumber,
  shipmentcreateddate
FROM
  netsuite.inboundshipment shipment
  left outer join netsuite.CUSTOMLIST976 shipmenttype on shipmenttype.id=shipment.custrecordcustrecord_inbound_type	
WHERE
  shipment_id_ns = 320