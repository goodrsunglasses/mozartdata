----- purpose sales qty for these models between feb 2024 and feb 2024 in channels goodr.com and .ca 
with skus as (
  SELECT
  product_id_edw,
  merchandise_class
FROM
  dim.product
where merchandise_class in ('BFGS','MACH GS','POP GS','CIRCLE GS')
)  
select 
  sum(case when merchandise_class = 'BFGS' then oi.quantity_sold else 0 end ) as bfg_qty,
  sum(case when merchandise_class = 'MACH GS' then oi.quantity_sold else 0 end ) as mach_qty,
  sum(case when merchandise_class = 'POP GS' then oi.quantity_sold else 0 end ) as pop_qty,
    sum(case when merchandise_class = 'CIRCLE GS' then oi.quantity_sold else 0 end ) as cg_qty,
from fact.order_item oi 
  left join fact.orders o on o.order_id_edw = oi.order_id_edw ---- only for channel and date 
  inner join skus on skus.product_id_edw = oi.product_id_edw 
where sold_date between '2024-02-01' and '2025-01-31' 
  and o.channel in ('Goodr.com','goodr.ca' )


--select * from fact.orders where channel is null and sold_date between '2024-02-01' and '2025-01-31'