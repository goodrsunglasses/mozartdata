SELECT
  TO_CHAR(
    DATE_TRUNC('WEEK', shipping_window_end_date),
    'MM/DD/YY'
  ) || '-' || TO_CHAR(
    DATE_TRUNC('WEEK', shipping_window_end_date) + 6,
    'MM/DD/YY'
  ) AS week_range,
  customer_name,
  sum(quantity_booked) total_booked
FROM
  one_off_requests.dc_staffing_calc calc
WHERE
  week_range IS NOT NULL
  
GROUP BY
  ALL
order by week_range