with rev_units as 
  (SELECT  date_trunc('month', sold_date) as month,
  o.channel, p.display_name, 
  p.sku,
  p.family as category,
  p.merchandise_class as model,
p.stage,
  design_tier,
  d2c_launch_date,
  b2b_launch_date,
  SUM(oi.quantity_sold) as units_sold , 
  sum(oi.revenue) as Revenue
  FROM fact.order_item oi
  LEFT JOIN dim.product p on p.sku = oi.sku
  LEFT JOIN fact.orders o  on o.order_id_edw = oi.order_id_edw
where family is not null 
group by all), 
  
  cogs as 
 ( SELECT date_trunc('month',period_end_date) as month,channel,sku,sum(total_cogs) as cogs
  FROM s8.cogs_transactions
group by all)

SELECT rev_units.*,cogs from rev_units LEFT JOIN cogs on cogs.month = rev_units.month and cogs.channel = rev_units.channel
and cogs.sku = rev_units.sku