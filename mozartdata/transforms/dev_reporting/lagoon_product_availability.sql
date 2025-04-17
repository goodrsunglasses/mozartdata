--Tentative idea here is to start with a list of all bin affecting transactions in netsuite, with special care being given to inbounds and outbound shipments, but still need to care about the rest
WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.netsuite_bin_inventory
  ),
  transfer_info AS (
    SELECT
      transfer_order_number_ns,
      transfer_order_transaction_id_ns,
      transaction_date,
      requested_date,
      expected_receipt_date,
      expected_ship_date,
      days_late shipping_location,
      receiving_location,
      status,
      memo,
      product_id_edw,
      item_id_ns,
      total_quantity,
      bin_id_ns,
      bin_number,
      quantity_committed,
      quantity_picked,
      quantity_packed,
      quantity_received,
      quantity_backordered
    FROM
      fact.transfer_order_item_detail detail
      LEFT OUTER JOIN fact.netsuite_inventory_assignment assign ON assign.transaction_line_id_ns = detail.transaction_line_id_ns
      AND detail.transaction_id_ns = assign.transaction_id_ns
  )
SELECT
  binventory.sku,
  transfer_info.transfer_order_number_ns,
  binventory.display_name,
  binventory.day,
  binventory.final_bin_id,
  final_binnumber,
  binventory.final_carried_quantity_available,
  final_quantity_on_hand,
  transfer_info.total_quantity
FROM
  binventory
  LEFT OUTER JOIN transfer_info ON transfer_info.product_id_edw = binventory.sku
  AND transfer_info.transaction_date = binventory.day
  AND binventory.final_bin_id = transfer_info.bin_id_ns