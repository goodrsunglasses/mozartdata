WITH 
grid_days as
  (
  select 
    row_number() over (order by seq4())-1 as days
  from 
    table(GENERATOR(ROWCOUNT => 91)) a 
  order by days 
  )
, grid_product as
  (
    select
      p.product_id_edw
    , d.days
    from
      dim.product p
    inner join
      goodr_reporting.launch_date_vs_earliest_sale_shopify ld
      on p.product_id_edw = ld.product_id_edw
      -- and earliest_d2c_sale >= '2023-01-01'
    inner join
      grid_days d
    on 1=1
  )
,  launch_orders as
  (
    SELECT
      oi.order_id_shopify
    , ld.product_id_edw
    , o.sold_date
    , ld.display_name
    , ld.collection
    , ld.family
    , ld.earliest_d2c_sale
    , sum(oi.amount_product_sold) launch_product_sales
    , sum(oi.quantity_sold) launch_product_quantity
    from
      fact.shopify_order_item oi
    inner join
      goodr_reporting.launch_date_vs_earliest_sale_shopify ld
      on ld.product_id_edw = oi.product_id_edw
      -- and ld.earliest_d2c_sale >= '2023-01-01'
    inner join
      fact.shopify_orders o
      on oi.order_id_shopify = o.order_id_shopify
    group by
      oi.order_id_shopify
    , ld.product_id_edw
    , ld.display_name
    , ld.collection
    , ld.family
    , ld.earliest_d2c_sale
    , o.sold_date
  ),
  total_sales as
  (
    SELECT
      lo.product_id_edw,
      (o.sold_date - lo.earliest_d2c_sale) as days_since_launch,
      sum(lo.launch_product_sales) as launch_product_sales,
      sum(lo.launch_product_quantity) as launch_product_quantity,
      SUM(o.amount_sold) total_sales,
      SUM(o.quantity_sold) total_quantity,
      COUNT(DISTINCT o.order_id_shopify) as orders_containing_launch
    FROM
     fact.shopify_order_line o 
      inner join
        launch_orders lo
      on o.order_id_shopify = lo.order_id_shopify
    -- WHERE  o.sold_date >= '2023-01-01' 
    group by lo.product_id_edw, days_since_launch
  )

SELECT
  gp.product_id_edw
, gp.days
, p.display_name
, p.collection
, p.family
, p.sku
, p.merchandise_class
, p.merchandise_department
, p.merchandise_division
, ld.earliest_d2c_sale as earliest_sale
, coalesce(ts.launch_product_sales,0) launch_product_sales
, coalesce(ts.launch_product_quantity,0) launch_product_quantity
, coalesce(ts.total_sales,0) total_sales
, coalesce(ts.total_quantity,0) total_quantity
, coalesce(ts.orders_containing_launch,0) orders_containing_launch
FROM
  grid_product gp
inner join
  dim.product p
  on gp.product_id_edw = p.product_id_edw
inner join
  goodr_reporting.launch_date_vs_earliest_sale_shopify ld
  on p.product_id_edw =ld.product_id_edw
left join
  total_sales ts
  on gp.product_id_edw = ts.product_id_edw
  and gp.days = ts.days_since_launch 
where p.merchandise_department = 'SUNGLASSES'
order by
  gp.product_id_edw
, days