SELECT
  quantity,
  dp.product_id_edw,
  location,
  dp.sku,
  p.display_name,
  CONCAT(demand_plan_created_date::string, ' demand plan') AS demand_plan_version,
  month
FROM
  fact.demand_plan dp
  left join dim.product p on p.product_id_edw = dp.product_id_edw
UNION
SELECT
  sum(quantity_fulfilled) as quantity,
  product_id_edw,
  location,
  sku,
  plain_name,
  'actual' AS demand_plan_version,
  DATE_TRUNC('MONTH', fulfillment_date) AS month
FROM
  goodr_reporting.fulfillment_locations_by_sku f
group by 
  product_id_edw,
  sku,
  location,
  plain_name,
  demand_plan_version,
  month