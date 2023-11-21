SELECT
  *
FROM
  fact.purchase_orders
WHERE
  quantity_ordered != quantity_billed
  OR quantity_ordered != quantity_received
  OR amount_ordered != amount_billed