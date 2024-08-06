with cte_runways as 
( SELECT DISTINCT
  o.customer_id_edw,
  cs.customer_id_shopify,
  ca.company
  
FROM fact.order_item oi
JOIN fact.orders o on o.order_id_edw = oi.order_id_edw
JOIN dim.product p on p.sku = oi.sku
JOIN fact.customer_shopify_map cs on cs.customer_id_edw = o.customer_id_edw
LEFT JOIN specialty_shopify.customer_address ca on cs.customer_id_shopify = ca.customer_id and ca.is_default = 'true'
WHERE 
  o.channel = 'Specialty'
  and o.sold_date > '2022-06-01'
  and p.merchandise_class = 'RUNWAYS'
order by o.customer_id_edw
  )

SELECT 
  c.customer_id_edw,
  ca.company
from archive.customer c 
join dim.customer dc on c.customer_id_edw = dc.customer_id_edw
JOIN fact.customer_shopify_map cs on cs.customer_id_edw = c.customer_id_edw
left join cte_runways r on r.customer_id_edw = c.customer_id_edw
LEFT JOIN specialty_shopify.customer_address ca on cs.customer_id_shopify = ca.customer_id and ca.is_default = 'true'


where c.first_order_date < '2023-09-01' and r.customer_id_edw is null and dc.customer_category = 'B2B'