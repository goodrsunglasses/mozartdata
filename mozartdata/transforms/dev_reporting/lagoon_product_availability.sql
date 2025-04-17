--Tentative idea here is to start with a list of all bin affecting transactions in netsuite, with special care being given to inbounds and outbound shipments, but still need to care about the rest
WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.bin_inventory_location
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
  current_past_inbound
WHERE
  transaction_date > '2025-04-17'