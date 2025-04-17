--Tentative idea here is to start with a list of all bin affecting transactions in netsuite, with special care being given to inbounds and outbound shipments, but still need to care about the rest
WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.bin_inventory_location
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
  *
FROM
  binventory
WHERE

   sku = 'BFG-BK-BK1-NR'
order by day asc
  --TO0001619