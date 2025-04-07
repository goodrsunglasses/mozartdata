SELECT
  inbound_shipment_id_ns,
  i.inbound_shipment_item_id_ns,
  i.item_id_ns,
  p.sku,
  expected_rate,
  quantity_billed,
  quantity_expected,
  quantity_received,
  quantity_remaining,
  receiving_location,
  inbound_shipment_amount,
  total_unit_cost,
  unit_landed_cost
FROM
  fact.inbound_shipment_item_detail i
left join
  dim.product p
  on i.item_id_ns = p.item_id_ns