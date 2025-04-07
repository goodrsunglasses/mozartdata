SELECT
  inbound_shipment_id_ns,
  i.inbound_shipment_item_id_ns,
  i.item_id_ns,
  p.product_id_edw,
  purchase_order_transaction_id_ns,
  purchase_order_number,
  p.sku,
  expected_rate,
  quantity_billed,
  quantity_expected,
  quantity_received,
  quantity_remaining,
  quantity_outstanding,
  receiving_location,
  inbound_shipment_amount,
  total_unit_cost,
  unit_landed_cost
FROM
  fact.inbound_shipment_item_detail i
left join
  dim.product p
  on i.item_id_ns = p.item_id_ns