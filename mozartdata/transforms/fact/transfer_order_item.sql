SELECT
  t.transaction_id_ns
, t.transaction_number_ns
, t.transfer_order_item_detail_id as transfer_order_item_id
, t.item_id_ns
, t.sku
, t.total_quantity
, t.quantity_committed
, t.quantity_allocated_supply
, t.quantity_picked
, t.quantity_packed
, t.quantity_received
, t.quantity_backordered
, t.quantity_allocated_demand
, lship.name as shipping_location
, lrec.name as receiving_location
, t.requested_date
, t.expected_receipt_date
, t.expected_ship_date
, t.days_late
, t.allocation_strategy
from
  staging.transfer_order_item_detail t
left join
  dim.location lship
  on t.shipping_location = lship.location_id_ns
left join
  dim.location lrec
  on t.receiving_location = lrec.location_id_ns
