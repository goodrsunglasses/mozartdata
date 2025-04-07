/*
Purpose: to show items in inbound shipments.
One row per inbound shipment id, which I think breaks down to one item per shipment?

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
  inb.shipmentnumber as inbound_shipment_number,
  inb_item.id as inbound_shipment_item_id_ns,
  inb_item.shipmentitemdescription as item,
  tranline.item as item_id_ns,
  inb_item.expectedrate as expected_rate,
  inb_item.quantitybilled as quantity_billed,
  quantityexpected as quantity_expected,
  quantityreceived as quantity_received,
  quantityremaining as quantity_remaining,
  quantityexpected-quantityreceived as quantity_outstanding,
  receivinglocation as receiving_location,
  shipmentitemamount as inbound_shipment_amount,
  totalunitcost as total_unit_cost,
  unitlandedcost as unit_landed_cost,
  inb_item.purchaseordertransaction as purchase_order_transaction_id_ns,
  tran.tranid as purchase_order_number,
  shipmentitemtransaction as shipment_item_id_ns
FROM
  netsuite.inboundshipment inb
  LEFT OUTER JOIN netsuite.inboundshipmentitem inb_item ON inb_item.inboundshipment = inb.id AND inb_item._fivetran_deleted = false
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.uniquekey = inb_item.shipmentitemtransaction
  LEFT OUTER JOIN netsuite.transaction tran ON inb_item.purchaseordertransaction = tran.id