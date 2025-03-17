SELECT  date_trunc('month', sold_date) as month,
  o.channel, p.display_name, 
  p.sku,
  p.family as category,
  p.merchandise_class as model,
p.stage,
  design_tier,
  SUM(oi.quantity_sold) as units_sold , 
  sum(oi.revenue) as Revenue,
  SUM(cogs.total_cogs) as COGS
  FROM fact.order_item oi
  LEFT JOIN dim.product p on p.sku = oi.sku
  LEFT JOIN fact.orders o  on o.order_id_edw = oi.order_id_edw
  LEFT JOIN s8.cogs_transactions cogs on cogs.order_id_edw = o.order_id_edw
where family is not null 
group by all