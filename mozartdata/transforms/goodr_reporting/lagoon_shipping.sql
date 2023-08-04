/*The purpose of this table is to count units and orders by channel everyday from 2022 - today.

row: one row per day per channel

aliases:

*/

SELECT
  trandate,
  channel,
  count(DISTINCT(order_num)),
  sum(distinct(total_quantity))
FROM dim.orders
WHERE 
  trandate >= '2022-01-01 00:00:00' and 
  location like 'HQ DC%'