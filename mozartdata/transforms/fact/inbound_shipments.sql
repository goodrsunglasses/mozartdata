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
  shipmentstatus as status,
  shipmentnumber as inbound_shipment_number,
  type.name as method,
  date(shipmentcreateddate) as created_date,
  date(expecteddeliverydate) as expected_delivery_date,
  date(actualdeliverydate) as actual_delivery_date,
  date(expectedshippingdate) as expected_deliveryshipping_date,
  date(actualshippingdate) as actual_shipping_date,
  date(custrecordcustrecord_actual_delivery_) as delivery_date,
  date(custrecordcustrecord_actual_ex_factory) as exit_factory_date,
  date(custrecordcustrecord_ata_to_destination) as ata_to_destination_date,
  date(custrecordcustrecord_atd_from_origin) as atd_from_origin_date,
  date(custrecordcustrecord_eta_to_destination) as eta_to_destination_date,
  date(custrecordcustrecord_etd_from_origin) as etd_from_origin_date,
  date(custrecordcustrecord_planned_delivery) as planned_delivery_date,
  inb.shipmentmemo as memo,
  custrecordgoodrponum as po_number,
  externaldocumentnumber as external_document_number,
  custrecordcustrecord_stord_inbound_messa as inbound_document_sent,
  vesselnumber as vessel_number,
  custrecordcontainernumber as container_number,
  billoflading as bill_of_lading,
  shipmentcreateddate as created_timestamp
FROM
  netsuite.inboundshipment inb
  left outer join netsuite.CUSTOMLIST976 type on type.id=inb.custrecordcustrecord_inbound_type