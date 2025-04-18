--This is gonna be an unhinged amount of CTE's but I want the steps to make sense blown up, refactoring can come later
WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.bin_inventory_location
  ),
  distinct_skus AS (
    SELECT DISTINCT
      sku,
      display_name
    FROM
      binventory
  ),
  future_days AS (
    SELECT
      DATE
    FROM
      dim.date
    WHERE
      DATE > current_date()
  ),
  gabby_join AS ( --as we all know she invented the cartesian join
    SELECT
      s.sku,
      s.display_name,
      c.DATE
    FROM
      distinct_skus s
      CROSS JOIN future_days c
  ),
  future_outbound AS (
    SELECT
      shipping_window_end_date,
      loc.name,
      item.sku,
      plain_name,
      sum(item.quantity_booked) total_so
    FROM
      fact.order_line line
      LEFT OUTER JOIN fact.order_item item ON item.order_id_edw = line.order_id_edw
      LEFT OUTER JOIN dim.location loc ON loc.location_id_ns = line.location
    WHERE
      record_type = 'salesorder' --only sales orders pre-emptively book outbounds
      AND shipping_window_end_date IS NOT NULL --only care about ones that have that filled in, thusly can say on a given day it will be decrimented
      AND shipping_window_end_date > current_date() --only care about future look forward
      AND location = 1 --hqdc lul
      AND sku IS NOT NULL --ignore tax and shipping
    GROUP BY
      ALL
    ORDER BY
      shipping_window_end_date asc
  )
SELECT
  gabby_join.DATE,
  gabby_join.sku,
  gabby_join.display_name,
  future_outbound.total_so
FROM
  gabby_join
  LEFT OUTER JOIN future_outbound ON future_outbound.sku = gabby_join.sku
  AND gabby_join.date = future_outbound.shipping_window_end_date
WHERE
  total_so IS NOT NULL