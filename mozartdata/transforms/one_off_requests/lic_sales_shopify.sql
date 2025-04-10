SELECT
  cast (date_trunc(month, created_at) as date) as sold_month,
  sum (case when p.family = 'LICENSING' then quantity else 0 end ) as lic_quantity,
  sum(sol.quantity) as total_quantity
--  new vs existing customer?? 
FROM
  shopify.order_line sol
  left  JOIN dim.product p ON p.product_id_d2c_shopify = sol.product_id
  left join shopify."ORDER" so on so.id = sol.order_id
where 
  sold_month >= '2022-01-01'
group by all 
order by 1 desc 

---select * from shopify."ORDER"