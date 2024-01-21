WITH
  orders AS (
    SELECT DISTINCT
      order_id_edw
    FROM
  fact.order_item_detail
  )