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
      p.item_id_ns
    , d.days
    from
      draft_dim.product p
    inner join
      one_off_requests.launch_date_vs_earliest_sale ld
      on p.item_id_ns = ld.item_id_ns
      and earliest_sale >= '2023-01-01'
    inner join
      grid_days d
    on 1=1
  )
,  launch_orders as
  (
    SELECT
      oi.order_id_edw
    , ld.item_id_ns
    , o.order_date_pst
    , ld.display_name
    , ld.collection
    , ld.family
    , ld.earliest_sale
    , sum(oi.amount_sold) launch_product_sales
    , sum(oi.quantity_sold) launch_product_quantity
    from
      fact.order_item oi
    inner join
      one_off_requests.launch_date_vs_earliest_sale ld
      on ld.item_id_ns = oi.item_id_ns
      and ld.earliest_sale >= '2023-01-01'
    inner join
      fact.orders o
      on oi.order_id_edw = o.order_id_edw
      and o.channel = 'Goodr.com'
    group by
      oi.order_id_edw
    , ld.item_id_ns
    , ld.display_name
    , ld.collection
    , ld.family
    , ld.earliest_sale
    , o.order_date_pst
  ),
  total_sales as
  (
SELECT
  lo.item_id_ns,
  (o.order_date_pst - lo.earliest_sale) as days_since_launch,
  sum(lo.launch_product_sales) as launch_product_sales,
  sum(lo.launch_product_quantity) as launch_product_quantity,
  SUM(o.amount_sold) total_sales,
  SUM(o.quantity_sold) total_quantity,
  COUNT(DISTINCT o.order_id_edw) as orders_containing_launch
FROM
 fact.orders o 
  inner join
    launch_orders lo
  on o.order_id_edw = lo.order_id_edw
WHERE  o.order_date_pst >= '2023-01-01' 
group by lo.item_id_ns, days_since_launch
  )

SELECT
  gp.item_id_ns
, gp.days
, p.display_name
, p.collection
, p.family
, ld.earliest_sale
, coalesce(ts.launch_product_sales,0) launch_product_sales
, coalesce(ts.launch_product_quantity,0) launch_product_quantity
, coalesce(ts.total_sales,0) total_sales
, coalesce(ts.total_quantity,0) total_quantity
, coalesce(ts.orders_containing_launch,0) orders_containing_launch
FROM
  grid_product gp
inner join
  draft_dim.product p
  on gp.item_id_ns = p.item_id_ns
inner join
  one_off_requests.launch_date_vs_earliest_sale ld
  on p.item_id_ns =ld.item_id_ns
left join
  total_sales ts
  on gp.item_id_ns = ts.item_id_ns
  and gp.days = ts.days_since_launch 
where
  gp.item_id_ns = 3653
order by
  gp.item_id_ns
, days

  /*
select * from draft_dim.product where display_name = 'Do Androids Dream of Electric Turtles?'
select * from one_off_requests.launch_date_vs_earliest_sale where item_id_ns = 1835
*/