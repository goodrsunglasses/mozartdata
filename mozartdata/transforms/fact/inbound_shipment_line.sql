SELECT
  inb.id inbound_shipment_id_ns,
  shipmentstatus as status,
  shipmentnumber as inb_number,
  type.name as method,
  date(custrecordcustrecord_actual_delivery_) as delivery_date,
  date(custrecordcustrecord_actual_ex_factory) as exit_factory_date,
  date(custrecordcustrecord_ata_to_destination) as ata_to_destination,
  date(custrecordcustrecord_atd_from_origin) as atd_from_origin,
  date(custrecordcustrecord_eta_to_destination) as eta_to_destination,
  date(custrecordcustrecord_etd_from_origin) as etd_from_origin,
  date(custrecordcustrecord_planned_delivery) as planned_delivery,
  custrecordgoodrponum as po_number,
  externaldocumentnumber as external_document_number,
  shipmentcreateddate as inb_created_timestemp
FROM
  netsuite.inboundshipment inb
  left outer join netsuite.CUSTOMLIST976 type on type.id=inb.custrecordcustrecord_inbound_type