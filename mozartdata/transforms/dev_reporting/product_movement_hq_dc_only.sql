WITH
  fulfillments AS (
    SELECT
      i.transfer_order_number_ns
    , listagg(i.transaction_number_ns,',') as item_fulfillment_number
    , i.status
    , i.transaction_date as actual_shipping_date
    , i.sku
    , sum(i.total_quantity) as quantity_shipped
    , i.shipping_location
    , i.receiving_location
    , case when i.shipping_location like 'HQ DC%' then 'Outbound'
        when i.receiving_location like 'HQ DC%' then 'Inbound' else 'Other' end as inbound_outbound
      FROM
        fact.transfer_order_item_detail i
      WHERE
        i.record_type = 'itemfulfillment'
      GROUP BY ALL
    ),
  receipts AS (
    SELECT
      i.transfer_order_number_ns
    , listagg(i.transaction_number_ns,',') as item_receipt_number
    , i.status
    , i.transaction_date as actual_received_date
    , i.sku
    , sum(i.total_quantity) as quantity_received
    , i.shipping_location
    , i.receiving_location
    , case when i.shipping_location like 'HQ DC%' then 'Outbound'
        when i.receiving_location like 'HQ DC%' then 'Inbound' else 'Other' end as inbound_outbound
      FROM
        fact.transfer_order_item_detail i
      WHERE
        i.record_type = 'itemreceipt'
      GROUP BY ALL
    ),
  transfer_orders as
  (
      SELECT
        i.transfer_order_number_ns
      , i.shipping_location
      , i.receiving_location
    , case when i.shipping_location like 'HQ DC%' then 'Outbound'
        when i.receiving_location like 'HQ DC%' then 'Inbound' else 'Other' end as inbound_outbound
      , i.sku
      , i.transfer_order_status
      , i.transfer_order_total_quantity
      , i.transfer_order_requested_date
      , i.transfer_order_expected_ship_date as estimated_shipping_date
      , i.transfer_order_expected_receipt_date as estimated_received_date

      FROM
        fact.transfer_order_item i
  ), all_transfer_orders as (
  SELECT DISTINCT
    t.transfer_order_number_ns as shipment_order_number
  , t.shipping_location
  , t.receiving_location
  , t.inbound_outbound
  , t.sku
  , t.transfer_order_status as shipment_status
  , t.transfer_order_total_quantity as total_quantity_ordered
  , t.transfer_order_requested_date as requested_date
  , t.estimated_shipping_date
  , f.actual_shipping_date
  , f.quantity_shipped
  , t.estimated_received_date AS transfer_order_estimated_received_date
  , CASE
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%ATL%' OR t.receiving_location LIKE '%ATL%') THEN
        dateadd(DAY, 8, coalesce(f.actual_shipping_date, t.estimated_shipping_date))
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%LAS%' OR t.receiving_location LIKE '%LAS%') THEN
        dateadd(DAY, 1, coalesce(f.actual_shipping_date, t.estimated_shipping_date))
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Cabana%' OR t.receiving_location LIKE '%Cabana%') THEN
        dateadd(DAY, 0, coalesce(f.actual_shipping_date, t.estimated_shipping_date))
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Flexport SB%' OR t.receiving_location LIKE '%Flexport SB%') THEN
        dateadd(DAY, 1, coalesce(f.actual_shipping_date, t.estimated_shipping_date))
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Lensabl DEN%' OR t.receiving_location LIKE '%Lensabl DEN%') THEN
        dateadd(DAY, 4, coalesce(f.actual_shipping_date, t.estimated_shipping_date))
      END AS calculated_received_date
  , CASE
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%ATL%' OR t.receiving_location LIKE '%ATL%') THEN
        dateadd(DAY, 14, transfer_order_requested_date)
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%LAS%' OR t.receiving_location LIKE '%LAS%') THEN
        dateadd(DAY, 8, transfer_order_requested_date)
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Cabana%' OR t.receiving_location LIKE '%Cabana%') THEN
        dateadd(DAY, 1, transfer_order_requested_date)
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Flexport SB%' OR t.receiving_location LIKE '%Flexport SB%') THEN
        dateadd(DAY, 1, transfer_order_requested_date)
      WHEN (t.shipping_location LIKE 'HQ DC%' OR t.receiving_location LIKE 'HQ DC%') AND
           (t.shipping_location LIKE '%Lensabl DEN%' OR t.receiving_location LIKE '%Lensabl DEN%') THEN
        dateadd(DAY, 10, transfer_order_requested_date)
      END AS target_sla_date
  , r.actual_received_date
  , r.quantity_received
    FROM
      transfer_orders t
      LEFT JOIN
        fulfillments f
          ON t.transfer_order_number_ns = f.transfer_order_number_ns
          AND t.sku = f.sku
      LEFT JOIN
        receipts r
          ON t.transfer_order_number_ns = r.transfer_order_number_ns
          AND t.sku = r.sku
          AND r.actual_received_date >= f.actual_shipping_date
    WHERE
      t.inbound_outbound != 'Other'
    QUALIFY
      rank() OVER (PARTITION BY t.transfer_order_number_ns, t.sku, f.actual_shipping_date ORDER BY f.actual_shipping_date, r.actual_received_date) =
      1

  ), inbounds as (
    SELECT
  s.inbound_shipment_number as shipment_order_number
, 'Factory' as shipping_location
, s.end_destination_location as receiving_location
, 'Inbound'
, i.sku
, s.status as shipment_status
, i.quantity_expected as total_quantity_ordered
, s.created_date as requested_date
, s.etd_from_origin_date as estimated_shipping_date
, s.atd_from_origin_date as actual_shipping_date
, i.quantity_expected as quantity_shipped
, s.planned_delivery_to_dc_date as estimated_received_date
, NULL
, null
, s.actual_delivery_to_dc_date as actual_received_date
, i.quantity_received
  FROM
    fact.inbound_shipment_item i--detail
    LEFT JOIN
      fact.inbound_shipments s
        ON i.inbound_shipment_id_ns = s.inbound_shipment_id_ns
where s.end_destination_location like 'HQ DC'

  )
SELECT
  *
from
  all_transfer_orders
union all
select
  *
from
  inbounds
    ORDER BY
      requested_date DESC