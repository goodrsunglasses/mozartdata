/*The purpose of this table is to count units and orders by channel everyday from 2022 - today.

row: one row per day per channel

aliases:

*/
SELECT
  date_trunc('month',fulfill.click) as month,
  avg(fulfill.click_to_ship) avg_click_to_ship,
  fulfill.channel,
  COUNT(DISTINCT (fulfill.order_id)) AS orders_count_quantity,
  SUM((quantity_items)) AS units_sum_quantity
FROM
fact.fulfillment_event fulfill
  left outer join dim.orders orders on orders.order_id = fulfill.order_id
WHERE
  fulfill.location LIKE '%HQ DC%'
  and fulfill.channel in ('Goodr.com','Specialty')
GROUP BY
  day,
  fulfill.channel
ORDER BY
  day asc