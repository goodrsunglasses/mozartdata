select 
  oid.plain_name,
  ics.location,
  c.name as channel,
  ap.periodname as posting_period,
  oid.item_id_ns,
  ics.sku,
  p.family as product_category,
  p.merchandise_class as model,
  sum(oid.amount_revenue) as revenue,
  sum(oid.total_quantity) as quantity,
  ics.average_cost as cost_per_unit,
  average_cost * quantity as total_cost,
from fact.order_item_detail oid
  LEFT OUTER JOIN netsuite.transaction t ON t.id = oid.transaction_id_ns
  left outer join dim.channel c on c.channel_id_ns=t.cseg7
  left join netsuite.accountingperiod ap on ap.id = t.postingperiod
  left join s8.inventory_cost_sheet ics on ics.item_id_ns = oid.item_id_ns and ics.location_id_ns = oid.location
  left join dim.product p on p.item_id_ns = oid.item_id_ns
where oid.record_type in ('cashsale', 'invoice') and posting_period like '%2024'
group by all