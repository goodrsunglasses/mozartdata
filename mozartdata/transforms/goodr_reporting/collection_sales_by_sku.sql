WITH 
grid_date as
  (
  select 
    * 
  from 
    dim.date
  where date >= '2023-01-01' and date <= '2025-01-01'
  )
  
, grid_product as
  (
    select
      p.item_id_ns
    , d.date
    from
      dim.product p
    inner join grid_date d on 1=1
    where item_id_ns is not null
      and p.family = 'LICENSING' 
      and p.replenish_flag = 'True'
  )
, collection_orders as
  (
    SELECT
      oi.order_id_edw
    , oi.item_id_ns
    , o.sold_date
    , oi.plain_name
    , p.collection
    , p.family as product_category
    , sum(oi.amount_product_sold) collection_product_sales
    , sum(oi.quantity_sold) collection_product_quantity
    from
      fact.order_item oi
    inner join
      fact.orders o
      on oi.order_id_edw = o.order_id_edw
      and o.channel = 'Goodr.com'
  left join 
    dim.product p
    on p.item_id_ns = oi.item_id_ns
where   product_category = 'LICENSING' 
  and o.sold_date >= '2022-01-01'
  and o.channel = 'Goodr.com'
  and p.replenish_flag = 'True'
    group by
      oi.order_id_edw
    , oi.item_id_ns
    , oi.plain_name
    , p.collection
    , p.family
    , o.sold_date
  ),

  total_sales as
  (
    SELECT
      co.item_id_ns,
      co.sold_date,
      sum(co.collection_product_sales) as collection_product_sales,
      sum(co.collection_product_quantity) as collection_product_quantity,
      SUM(o.amount_product_sold) total_sales,
      SUM(o.quantity_sold) total_quantity,
      COUNT(DISTINCT o.order_id_edw) as orders_containing_collection
    FROM
     fact.orders o 
      inner join
        collection_orders co
      on o.order_id_edw = co.order_id_edw
      and o.sold_date = co.sold_date
    WHERE  o.sold_date >= '2022-01-01' 
    group by co.item_id_ns, co.sold_date
  )

SELECT
  gp.date
, gp.item_id_ns
, p.display_name
, p.collection
, p.family
, p.sku
, p.merchandise_class
, p.merchandise_department
, p.merchandise_division
, coalesce(ts.collection_product_sales,0) collection_product_sales
, coalesce(ts.collection_product_quantity,0) collection_product_quantity
, coalesce(ts.total_sales,0) total_sales
, coalesce(ts.total_quantity,0) total_quantity
, coalesce(ts.orders_containing_collection,0) orders_containing_collection
FROM
grid_product gp
inner join
  dim.product p
  on gp.item_id_ns = p.item_id_ns
left join
  total_sales ts
  on gp.item_id_ns = ts.item_id_ns
where p.merchandise_department = 'SUNGLASSES'
order by
  gp.item_id_ns
, date
---