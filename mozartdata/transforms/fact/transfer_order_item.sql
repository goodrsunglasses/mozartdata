/*
 purpose: This table is 1 row per transfer order + item. Some orders may have multiple fulfillments or receipts so we capture min and max
 primary_key: transfer_order_item_id
 */
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
  , concat(t.transfer_order_number_ns,'_',t.sku) as transfer_order_item_id
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
  , min(t.requested_date) as transfer_order_requested_date
  , min(t.expected_receipt_date) as transfer_order_expected_receipt_date
  , min(t.expected_ship_date) as transfer_order_expected_ship_date
  , max(t.days_late) as transfer_order_days_late
  , min(t.allocation_strategy) as transfer_order_allocation_strategy
    FROM
      transfer_order_item_detail t
    WHERE
      record_type = 'transferorder'
    GROUP BY ALL
  ),
irs as
  (
    SELECT
      t.transfer_order_number_ns
    , t.transfer_order_transaction_id_ns
    , t.product_id_edw
    , t.item_id_ns
    , t.sku
    , sum(t.total_quantity) as quantity_received
    , min(t.transaction_date) as earliest_received_date
    , max(t.transaction_date) as latest_received_date
    , count(distinct t.transaction_id_ns) item_receipt_count
    FROM
      transfer_order_item_detail t
    WHERE
      t.record_type = 'itemreceipt'
    GROUP BY ALL
  ),
ifs as
  (
    SELECT
      t.transfer_order_number_ns
    , t.transfer_order_transaction_id_ns
    , t.product_id_edw
    , t.item_id_ns
    , t.sku
    , sum(t.total_quantity) as quantity_fulfilled
    , min(t.transaction_date) as earliest_fulfilled_date
    , max(t.transaction_date) as latest_fulfilled_date
    , count(distinct t.transaction_id_ns) item_fulfillment_count
    FROM
      transfer_order_item_detail t
    WHERE
      t.record_type = 'itemfulfillment'
    GROUP BY ALL
  )

SELECT
  t.*
, ifs.quantity_fulfilled
, ifs.earliest_fulfilled_date
, ifs.latest_fulfilled_date
, ifs.item_fulfillment_count
, irs.quantity_received
, irs.earliest_received_date
, irs.latest_received_date
, irs.item_receipt_count
from
  transfer_orders t
left join
  ifs
  on t.transfer_order_transaction_id_ns = ifs.transfer_order_transaction_id_ns
  and t.item_id_ns = ifs.item_id_ns
left join
  irs
  on t.transfer_order_transaction_id_ns = irs.transfer_order_transaction_id_ns
  and t.item_id_ns = irs.item_id_ns