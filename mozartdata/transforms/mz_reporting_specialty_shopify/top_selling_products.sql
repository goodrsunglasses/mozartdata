-- Get all products and show the number of items sold.

SELECT
  name,
  sum(quantity) AS quantity
FROM
  mz_reporting_specialty_shopify.inventory
GROUP BY 1