SELECT
  t.transaction_id_ns
, t.transaction_number_ns
, t.transaction_date
, t.transaction_created_timestamp_pst
, t.transaction_created_date_pst
, t.record_type
, t.status
, t.full_status
, t.memo
, t.firmed_flag
, t.use_item_cost_flag
, t.icoterm
, t.amazon_shipment_id
, t.ship_by_date
, sum(t.total_quantity) as total_quantity
, sum(t.quantity_committed) as quantity_committed
, sum(t.quantity_allocated_supply) as quantity_allocated_supply
, sum(t.quantity_picked) as quantity_picked
, sum(t.quantity_received) as quantity_received
, max(lship.name) as shipping_location
, max(lrec.name) as receiving_location
, min(t.requested_date) as requested_date
, max(t.expected_receipt_date) as expected_receipt_date
, max(t.expected_ship_date) as expected_ship_date
, max(days_late) as days_late
, max(t.allocation_strategy) as allocation_strategy
from
  staging.transfer_order_item_detail t
left join
  dim.location lship
  on t.shipping_location = lship.location_id_ns
left join
  dim.location lrec
  on t.receiving_location = lrec.location_id_ns
