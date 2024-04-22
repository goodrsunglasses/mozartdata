SELECT
  quantity,
  product_id_edw,
  location,
  sku,
  CONCAT(demand_plan_created_date::string, ' demand plan') AS demand_plan_version,
  month
FROM
  fact.demand_plan dp
UNION
SELECT
  sum(quantity_fulfilled) as quantity,
  product_id_edw,
  location,
  sku,
  'actual' AS demand_plan_version,
  DATE_TRUNC('MONTH', fulfillment_date) AS month
FROM
  one_off_requests.fulfillment_locations_by_sku f
group by 
  product_id_edw,
  sku,
  location,
  demand_plan_version,
  month