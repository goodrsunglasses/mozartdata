--Tentative idea here is to start with a list of all bin affecting transactions in netsuite, with special care being given to inbounds and outbound shipments, but still need to care about the rest
WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.bin_inventory_location
  ),
  shipments AS (
    SELECT
      detail.inbound_shipment_id_ns,
      detail.inbound_shipment_number,
      end_destination_location,
      detail.item_id_ns,
      prod.sku,
      prod.display_name,
      created_date,
      quantity_expected,
      quantity_received,
      planned_delivery_to_dc_date,
      actual_delivery_to_dc_date
    FROM
      fact.inbound_shipment_item_detail detail
      LEFT OUTER JOIN fact.inbound_shipments ship ON ship.inbound_shipment_id_ns = detail.inbound_shipment_id_ns
      LEFT OUTER JOIN dim.product prod ON prod.item_id_ns = detail.item_id_ns
  ),
  current_past_inbound AS (
    SELECT
      transaction_date,
      shipping_location,
      receiving_location,
      item_id_ns,
      sku,
      sum(total_quantity) total_tos
    FROM
      fact.transfer_order_item_detail
    WHERE
      receiving_location = 'HQ DC'
      AND record_type = 'itemreceipt'
    GROUP BY
      ALL
  )
SELECT
  *
FROM
  shipments
WHERE
  planned_delivery_to_dc_date > '2025-04-17'