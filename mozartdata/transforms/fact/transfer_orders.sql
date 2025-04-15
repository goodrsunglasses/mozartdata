WITH
  transfer_orders AS (
    SELECT
      t.transaction_id_ns
    , t.transaction_number_ns
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
    , sum(t.total_quantity) AS total_quantity
    , sum(t.quantity_committed) AS quantity_committed
    , sum(t.quantity_allocated_supply) AS quantity_allocated_supply
    , sum(t.quantity_picked) AS quantity_picked
    , sum(t.quantity_received) AS quantity_received
    , max(t.shipping_location) AS shipping_location
    , max(t.receiving_location) AS receiving_location
    , min(t.requested_date) AS requested_date
    , max(t.expected_receipt_date) AS expected_receipt_date
    , max(t.expected_ship_date) AS expected_ship_date
    , max(t.days_late) AS transfer_order_days_late
    , max(t.allocation_strategy) AS allocation_strategy
      FROM
        fact.transfer_order_item_detail t
      WHERE
        t.record_type = 'transferorder'
      GROUP BY ALL
    )
, transfer_items AS
    (
    SELECT
      t.transfer_order_number_ns
    , t.transfer_order_transaction_id_ns
    , sum(t.quantity_fulfilled) AS quantity_fulfilled
    , min(t.earliest_fulfilled_date) AS earliest_fulfilled_date
    , max(t.latest_fulfilled_date) AS latest_fulfilled_date
    , sum(t.item_fulfillment_count) AS item_fulfillment_count
    , sum(t.quantity_received) AS quantity_received
    , min(t.earliest_received_date) AS earliest_received_date
    , max(t.latest_received_date) AS latest_received_date
    , sum(t.item_receipt_count) AS item_receipt_count
      FROM
        fact.transfer_order_item t
      GROUP BY ALL
    )
SELECT
  t.transaction_id_ns AS transfer_order_id_ns
, t.transaction_number_ns AS transfer_order_number_ns
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
, t.total_quantity
, t.quantity_committed
, t.quantity_allocated_supply
, t.quantity_picked
, t.quantity_received
, t.shipping_location
, t.receiving_location
, t.requested_date
, t.expected_receipt_date
, t.expected_ship_date
, t.transfer_order_days_late
, t.allocation_strategy
, i.quantity_fulfilled
, i.earliest_fulfilled_date
, i.latest_fulfilled_date
, i.item_fulfillment_count
, i.quantity_received
, i.earliest_received_date
, i.latest_received_date
, i.item_receipt_count
  FROM
    transfer_orders t
    LEFT JOIN
      transfer_items i
        ON t.transaction_id_ns = i.transfer_order_transaction_id_ns