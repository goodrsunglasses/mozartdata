-- Calculates the average total line items price for new and repeat customers for the past 3 months from the orders table. Uses the AVG function to calculate the average price for each group, rounded to two decimal points.

SELECT
  new_vs_repeat,
  ROUND(AVG(CASE WHEN num_months_ago = 3 THEN total_line_items_price END),2) as "3 Months Ago",
  ROUND(AVG(CASE WHEN num_months_ago = 2 THEN total_line_items_price END),2) as "2 Months Ago",
  ROUND(AVG(CASE WHEN num_months_ago = 1 THEN total_line_items_price END),2) as "1 Month Ago"
FROM
  mz_reporting_shopify.orders
WHERE
  num_months_ago <= 3 -- Filters the data for the past 3 months only.
GROUP BY
  1