with poo as (
    SELECT  
      o.sold_date as date,
      o.channel, 
      coalesce(old_map.display_name, new_map.display_name, p.display_name) display_name, 
      p.sku,
      p.family,
      p.merchandise_class,
      p.stage,
      sum(oi.quantity_sold) as qty,count(distinct o.customer_id_edw) as customers, 
      sum(oi.revenue) as revenue
    FROM 
      fact.order_item oi
    INNER JOIN 
      dim.product p on p.sku = oi.sku
    LEFT JOIN 
      fact.orders o  on o.order_id_edw = oi.order_id_edw
    LEFT JOIN 
      dim.old_to_new_sku_map  old_map on old_map.old_sku = oi.sku -- to get display_name for old sku 
    LEFT JOIN 
      dim.old_to_new_sku_map  new_map on new_map.new_sku = oi.sku -- to get the display_name for new sku 
    group by all
)

select 
  * 
from 
  poo