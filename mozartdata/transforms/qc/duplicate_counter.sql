SELECT
  COUNT(order_id_edw) counter, -- replace with what ever field you want to count
  order_id_edw
FROM
  dim.orders-- replace with what ever table you want it from
GROUP BY
 order_id_edw

HAVING
  counter > 1