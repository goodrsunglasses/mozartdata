SELECT
  TO_CHAR(
    DATE_TRUNC('WEEK', shipping_window_end_date),
    'MM/DD/YY'
  ) || '-' || TO_CHAR(
    DATE_TRUNC('WEEK', shipping_window_end_date) + 6,
    'MM/DD/YY'
  ) AS week_range,
  normalized_name,
  sum(quantity_booked) total_booked,
  sum(round((total_time_minutes/60),2)) as total_hours,
  count(distinct order_id_edw) order_count
FROM
  one_off_requests.dc_staffing_calc calc
WHERE
  week_range IS NOT NULL
GROUP BY
  ALL
order by week_range desc