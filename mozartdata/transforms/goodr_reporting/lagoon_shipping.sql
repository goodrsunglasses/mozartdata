/*The purpose of thsi query is to fulfill Will's request to get all goodr.com and specialty data coming out of the HQDC location from only 2022..

row: one row per month per channel

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
   and click BETWEEN '2022-01-01T00:00:00Z' and '2022-12-31T23:59:59Z'
GROUP BY
  month,
  fulfill.channel
ORDER BY
  month desc