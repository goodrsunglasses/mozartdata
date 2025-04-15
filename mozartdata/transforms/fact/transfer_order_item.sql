WITH
  transfer_order_item_detail as
  (
    SELECT
      *
    from
      fact.transfer_order_item_detail
  ),
transfer_orders AS (
  SELECT
    t.transfer_order_number_ns
  , t.transfer_order_transaction_id_ns
  , t.status as transfer_order_status
  , t.ship_by_date
  , t.product_id_edw
  , t.item_id_ns
  , t.sku
  , sum(t.total_quantity) as transfer_order_total_quantity
  , sum(t.quantity_committed) as transfer_order_quantity_committed
  , sum(t.quantity_allocated_supply) as transfer_order_quantity_allocated_supply
  , sum(t.quantity_picked) as transfer_order_quantity_picked
  , sum(t.quantity_packed) as transfer_order_quantity_packed
  , sum(t.quantity_received) as transfer_order_quantity_received
  , sum(t.quantity_backordered) as transfer_order_quantity_backordered
  , sum(t.quantity_allocated_demand) as transfer_order_quantity_allocated_demand
  , t.shipping_location
  , t.receiving_location
  , t.requested_date as transfer_order_requested_date
  , t.expected_receipt_date as transfer_order_expected_receipt_date
  , t.expected_ship_date as transfer_order_expected_ship_date
  , t.days_late as transfer_order_days_late
  , t.allocation_strategy as transfer_order_allocation_strategy
    FROM
      transfer_order_item_detail t
    WHERE
      record_type = 'transferorder'
  )