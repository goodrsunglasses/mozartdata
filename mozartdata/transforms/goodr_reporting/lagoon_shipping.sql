/*The purpose of this table is to count units and orders by channel everyday from 2022 - today.

row: one row per day per channel

aliases:

*/
SELECT
  date_tran,
  channel,
  count(DISTINCT(order_id)) as orders_count_quantity,
  sum(distinct(quantity_items)) as units_sum_quantity
FROM
  dim.orders
WHERE
  date_tran >= '2022-01-01 00:00:00'
  AND location LIKE '%HQ DC%'
group by date_tran ,channel
order by date_tran asc