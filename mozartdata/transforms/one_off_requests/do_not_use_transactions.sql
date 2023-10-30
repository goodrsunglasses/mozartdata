WITH
  sold AS (
    SELECT
      order_id_edw,
      transaction_id_ns,
  item_id_ns
    FROM
      fact.order_item_detail
  where recordtype = 'salesorder'
  )
WHERE
  ordernum = 'SO0958613'
ORDER BY
  ordernum asc