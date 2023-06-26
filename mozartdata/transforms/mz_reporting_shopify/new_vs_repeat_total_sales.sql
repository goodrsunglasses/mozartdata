-- Calculates the total line items price for new and repeat customers for the past 3 months from the orders table.

SELECT
  new_vs_repeat,
  SUM(CASE WHEN num_months_ago = 3 THEN total_line_items_price ELSE 0 END) as "3 Months Ago",
  SUM(CASE WHEN num_months_ago = 2 THEN total_line_items_price ELSE 0 END) as "2 Months Ago",
  SUM(CASE WHEN num_months_ago = 1 THEN total_line_items_price ELSE 0 END) as "1 Month Ago"
FROM
  mz_reporting_shopify.orders
WHERE
  num_months_ago <= 3 -- Filters the data for the past 3 months only.
GROUP BY
  1
  ;