/*The purpose of this table is to count units and orders by channel everyday from 2022 - today.

row: one row per day per channel

aliases:

*/
SELECT
  date_tran,
  channel,
  COUNT(DISTINCT (order_id)) AS orders_count_quantity,
  SUM(DISTINCT (quantity_items)) AS units_sum_quantity
FROM
  dim.orders
WHERE
  date_tran >= '2022-01-01 00:00:00'
  AND location LIKE '%HQ DC%'
GROUP BY
  date_tran,
  channel
ORDER BY
  date_tran asc