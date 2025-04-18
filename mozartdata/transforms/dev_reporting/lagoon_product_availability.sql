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
      DATE BETWEEN current_date() AND current_date()  + 365
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
  future_outbound AS ( --Current business logic assumption, is that TO's are not entered ahead of time, the second they go in they decriment inventory, Margie quote here
    SELECT
      shipping_window_end_date,
      loc.name,
      item.sku,
      plain_name,
      sum(item.quantity_booked) total_outbound
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
  ),
  future_inbound AS ( --Current business logic assumption, is that future inbounds are only booked via shipments
    SELECT
      transfer_order_estimated_received_date, --Using this because its the only thing 
      receiving_location,
      sku,
      sum(total_quantity_ordered) total_inbound
    FROM
      dev_reporting.product_movement_hq_dc_only
    WHERE
      inbound_outbound = 'Inbound'
      AND transfer_order_estimated_received_date > current_date()
    GROUP BY
      ALL
    ORDER BY
      transfer_order_estimated_received_date desc
  )
SELECT
  gabby_join.DATE,
  gabby_join.sku,
  gabby_join.display_name,
  future_outbound.total_outbound,
  future_inbound.total_inbound
FROM
  gabby_join
  LEFT OUTER JOIN future_outbound ON future_outbound.sku = gabby_join.sku
  AND gabby_join.date = future_outbound.shipping_window_end_date
  LEFT OUTER JOIN future_inbound ON future_inbound.sku = gabby_join.sku
  AND gabby_join.date = future_inbound.transfer_order_estimated_received_date
order by date asc