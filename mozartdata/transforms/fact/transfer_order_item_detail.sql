/*
Purpose: This table has all the transactional detail for transfer orders, including their item fulfillments and item receipts.
Primary Key: transfer_order_item_detail_id
*/
SELECT
  t.transfer_order_number_ns
, t.transaction_id_ns
, t.transaction_number_ns
, t.transfer_order_item_detail_id
, t.transaction_date
, t.record_type
, t.status
, t.full_status
, t.memo
, t.firmed_flag
, t.use_item_cost_flag
, t.incoterm
, t.amazon_shipment_id
, t.ship_by_date
, t.created_from_transaction_id_ns
, t.item_type
, t.transaction_line_id_ns
, t.product_id_edw
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
, lship.name AS shipping_location
, lrec.name AS receiving_location
, t.requested_date
, t.expected_receipt_date
, t.expected_ship_date
, t.days_late
, allocation_strategy
  FROM
    staging.transfer_order_item_detail t
  LEFT JOIN
    dim.location lship
    ON t.shipping_location = lship.location_id_ns
  LEFT JOIN
    dim.location lrec
    ON t.receiving_location = lrec.location_id_ns