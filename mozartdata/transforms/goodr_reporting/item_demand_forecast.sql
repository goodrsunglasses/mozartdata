select
  forecast_created_date
, forecast_month
, location
, sku
, sum(quantity) quantity
from 
  fact.demand_plan dp
group by
  location
, sku