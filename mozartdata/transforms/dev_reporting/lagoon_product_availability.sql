WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.bin_inventory_location
  ),
  gabby_math AS (
    SELECT
      *
    FROM
      dim.date
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
  *
FROM
  gabby_math
ORDER BY
  DAY desc