select 
  dd.itemdemandplan as demand_plan_id_ns
, dp.location as location_id_ns
, p.product_id_edw
, l.name as location
, p.sku
, date(dp.projectionstartdate) as demand_plan_created_date
, date(date_trunc(month,dd.startdate)) as month
, dd.quantity as quantity
from 
  netsuite.itemdemandplan dp
inner join
  netsuite.itemdemandplandemandplandetail dd
  on dd.itemdemandplan = dp.demandplanid
left join
  dim.product p
  on dp.item = p.item_id_ns
left join
  dim.location l
  on dp.location = l.location_id_ns