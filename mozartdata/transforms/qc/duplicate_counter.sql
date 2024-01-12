SELECT
  COUNT(order_line_id) counter, -- replace with what ever field you want to count
  order_line_id
FROM
  draft_fact.order_line -- replace with what ever table you want it from
GROUP BY
 order_line_id
HAVING
  counter > 1