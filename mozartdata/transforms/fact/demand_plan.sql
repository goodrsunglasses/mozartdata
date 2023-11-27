select 
  dd.itemdemandplan as demand_plan_id_ns
, dp.location as location_id_ns
, p.product_id_edw
, l.name as location
, p.sku
, date(dp.projectionstartdate) as forecast_created_date
, date(date_trunc(month,dd.startdate)) as forecast_month
, dd.quantity
from 
  netsuite.itemdemandplan dp
inner join
  netsuite.itemdemandplandemandplandetail dd
  on dd.itemdemandplan = dp.demandplanid
left join
  dim.product p
  on dp.item = p.product_id_edw
left join
  dim.location l
  on dp.location = l.location_id_ns