SELECT
  inb.id inbound_shipment_id_ns,
  inb.shipmentnumber as inbound_shipment_number,
  inb_item.shipmentitemdescription as item,
  tranline.item as item_id_ns,
  inb_item.expectedrate as expected_rate,
  inb_item.quantitybilled as quantity_billed,
  quantityexpected as quantity_expected,
  quantityreceived as quantity_received,
  quantityremaining as quantity_remaining,
  receivinglocation as receiving_location,
  shipmentitemamount as inbound_shipment_amount,
  totalunitcost as total_unit_cost,
  unitlandedcost as unit_landed_cost,
  purchaseordertransaction as purchase_order_id_ns,
  shipmentitemtransaction as shipment_item_id_ns
FROM
  netsuite.inboundshipment inb
  LEFT OUTER JOIN netsuite.inboundshipmentitem inb_item ON inb_item.inboundshipment = inb.id
  LEFT OUTER JOIN netsuite.transactionline tranline ON tranline.uniquekey = inb_item.shipmentitemtransaction