/*
Purpose: to show the line-level details of an inbound shipment.
One row per inbound shipment id

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/
with root_table as (
    select
      *
    from
      mozart.pipeline_root_table
)
SELECT
  inb.id as inbound_shipment_id_ns,
  case
    when shipmentstatus = 'partiallyReceived' then 'Partially Receieved'
    when shipmentstatus = 'inTransit' then 'In Transit'
    when shipmentstatus = 'toBeShipped' then 'To Be Shipped'
    when shipmentstatus = 'closed' then 'Closed'
    when shipmentstatus = 'received' then 'Received'
    else shipmentstatus
    end as status,
  shipmentnumber as inbound_shipment_number,
  type.name as inbound_type,
  date(shipmentcreateddate) as created_date,
  date(expectedshippingdate) as expected_shipping_date,
  date(actualshippingdate) as actual_shipping_date,
  date(expecteddeliverydate) as expected_delivery_date,
  date(actualdeliverydate) as actual_delivery_date,
  date(custrecordcustrecord_planned_delivery) as planned_delivery_to_dc_date,
  date(custrecordcustrecord_actual_delivery_) as actual_delivery_to_dc_date,
  date(custrecordcustrecord_actual_ex_factory) as exit_factory_date,
  date(custrecordcustrecord_eta_to_destination) as eta_to_destination_port_date,
  date(custrecordcustrecord_ata_to_destination) as ata_to_destination_port_date,
  date(custrecordcustrecord_etd_from_origin) as etd_from_origin_date,
  date(custrecordcustrecord_atd_from_origin) as atd_from_origin_date,
  v.name as freight_forwarder,
  l.name as end_destination_location,
  inb.shipmentmemo as memo,
  custrecordgoodrponum as po_number,
  externaldocumentnumber as external_document_number,
  custrecordcustrecord_stord_inbound_messa as inbound_document_sent,
  vesselnumber as vessel_number,
  custrecordcontainernumber as container_number,
  billoflading as bill_of_lading,
  case when custrecordinb_appointment_schedule = 'T' then true else false end as appointment_schedule_flag,
  date(custrecordinb_appointment_date) as appointment_date,
  shipmentcreateddate as created_timestamp
FROM
  netsuite.inboundshipment inb
  left outer join netsuite.CUSTOMLIST976 type on type.id=inb.custrecordcustrecord_inbound_type
  left outer join dim.vendors v on inb.custrecord161 = v.vendor_id_ns
  left outer join dim.location l on inb.custrecord162 = l.location_id_ns