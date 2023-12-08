--- cte to determine the month and week of the start of the shipping window
with cte_ship_start as 
(
  SELECT 
  ol.order_id_edw,
  ol.shipping_window_start_date,
  d.month_name as shipping_window_start_month,
  d.week_of_year as shipping_window_start_week,
  d.year as  shipping_window_start_year

  FROM
  fact.order_line ol
  LEFT JOIN dim.date d on ol.shipping_window_start_date = d.date

  WHERE
  ol.channel = 'Key Account'
  and ol.record_type = 'salesorder'

  ORDER BY ol.transaction_date desc
)

--- cte to determine the month and week of the end of the shipping window
, cte_ship_end as 
(
  SELECT 
  ol.order_id_edw,
  ol.shipping_window_end_date,
  d.month_name as shipping_window_end_month,
  d.week_of_year as shipping_window_end_week,
  d.year as  shipping_window_end_year

  FROM
  fact.order_line ol
  LEFT JOIN dim.date d on ol.shipping_window_start_date = d.date

  WHERE
  ol.channel = 'Key Account'
  and ol.record_type = 'salesorder'

  ORDER BY ol.transaction_date desc
) 
  
SELECT
  ol.channel,
  ol.customer_id_ns as customer_internal_ns_id,
  ol.transaction_date,
  ol.order_id_edw,
  o.amount_booked,
  ol.shipping_window_start_date,
  cte_ss.shipping_window_start_month,
  cte_ss.shipping_window_start_week,
  cte_ss.shipping_window_start_year,
  ol.shipping_window_end_date,
  cte_se.shipping_window_end_month,
  cte_se.shipping_window_end_week,
  cte_se.shipping_window_end_year,
  cnm.customer_id_ns
  
FROM
  fact.order_line ol
LEFT JOIN fact.customer_ns_map cnm on cnm.customer_internal_id_ns = ol.customer_id_ns
LEFT JOIN cte_ship_start cte_ss on cte_ss.order_id_edw = ol.order_id_edw
LEFT JOIN cte_ship_end cte_se on cte_se.order_id_edw = ol.order_id_edw
LEFT JOIN fact.orders o on ol.order_id_edw = o.order_id_edw

WHERE
  ol.channel = 'Key Account'
  and ol.record_type = 'salesorder'

ORDER BY ol.transaction_date desc