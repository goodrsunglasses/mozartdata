SELECT
  COUNT(order_item_detail_id) counter, -- replace with what ever field you want to count
  order_item_detail_id
FROM
  staging.order_item_detail-- replace with what ever table you want it from
GROUP BY
 order_item_detail_id
HAVING
  counter > 1