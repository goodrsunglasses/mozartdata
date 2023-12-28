WITH 
  product_list as
  (
    SELECT
      p.product_id_edw
    , p.sku
    , p.display_name
    , p.family
    , p.collection
    , p.merchandise_class
    , p.merchandise_department
    , p.merchandise_division
    , p.d2c_launch_date
    , p.b2b_launch_date
    FROM
      dim.product p
    WHERE
      p.sku IN (
      'G00288-OG-GD7-RF' --We Struck Goldschlaeger
      , 'G00229-OG-IB2-RF' --Bingo! Dino DNA
      )
  /* all 2023 launches */
  or 
    date_trunc(year, p.d2c_launch_date) = '2023-01-01'
  /* remove this bit */
  ),
  po as
  (
    select
      p.product_id_edw
      , min(po.purchase_date) first_po_date
      , sum(poi.quantity_ordered) total_quantity_ordered
    from
      fact.purchase_order_item poi
    inner join
      fact.purchase_orders po
      on poi.order_id_edw = po.order_id_edw
    inner join
      product_list p
      on poi.product_id_edw = p.product_id_edw
    group by
      p.product_id_edw
    ),
  orders as
  (
    select
      p.product_id_edw
      , min(case when b2b_d2c = 'D2C' then o.sold_date end) first_d2c_order_date
      , min(case when b2b_d2c = 'B2B' then o.booked_date end) first_b2b_order_date
      , sum(oi.quantity_sold) total_quantity_sold
    from
      fact.order_item oi
    inner join
      fact.orders o
      on oi.order_id_edw = o.order_id_edw
    inner join
      product_list p
      on oi.product_id_edw = p.product_id_edw
    group by
      p.product_id_edw 
  ),
  cumulative_sales as
  (
    SELECT 
      oi.product_id_edw,
      o.sold_date,
      SUM(oi.quantity_sold) OVER (PARTITION BY oi.product_id_edw ORDER BY o.sold_date) AS cumulative_sold
    from
      fact.order_item oi
    inner join
      product_list pl
      on oi.product_id_edw = oi.product_id_edw
    inner join
      fact.orders o
    on oi.order_id_edw = o.order_id_edw
    ORDER BY 
      oi.product_id_edw
    , o.sold_date
  ),
  product_list_expanded as
  (
select 
  pl.sku
, pl.display_name
, pl.family
, pl.merchandise_class
, po.first_po_date
, po.total_quantity_ordered
, pl.d2c_launch_date
, pl.b2b_launch_date
, o.first_d2c_order_date
, o.first_b2b_order_date
, least(coalesce(o.first_d2c_order_date,current_date()),coalesce(o.first_b2b_order_date,current_date())) earliest_sale
, o.total_quantity_sold
, pl.product_id_edw
from
  product_list pl
left join
  po
  on po.product_id_edw = pl.product_id_edw
left join
  orders o
  on o.product_id_edw = pl.product_id_edw
),
  days_to as
  (
SELECT
 cs.product_id_edw
,  min(CASE 
        WHEN cs.cumulative_sold >= 0.5 * ple.total_quantity_ordered THEN DATEDIFF(day, least(coalesce(ple.first_d2c_order_date,current_date()),coalesce(ple.first_b2b_order_date,current_date())), cs.sold_date)
        ELSE NULL
    END)  AS days_to_50_percent
,  min(CASE 
        WHEN cs.cumulative_sold >= 0.9 * ple.total_quantity_ordered THEN DATEDIFF(day, least(ple.first_d2c_order_date,ple.first_b2b_order_date), cs.sold_date)
        ELSE NULL
    END) AS days_to_90_percent
,  min(CASE 
        WHEN cs.cumulative_sold >= 1 * ple.total_quantity_ordered THEN DATEDIFF(day, least(ple.first_d2c_order_date,ple.first_b2b_order_date), cs.sold_date)
        ELSE NULL
    END) AS days_to_sold_out
FROM cumulative_sales cs
INNER JOIN
    product_list_expanded ple
    on cs.product_id_edw = ple.product_id_edw
group by
cs.product_id_edw)

SELECT 
  ple.*
, dt.days_to_50_percent
, days_to_90_percent
, days_to_sold_out
FROM
  product_list_expanded ple
left join
  days_to dt
  on ple.product_id_edw = dt.product_id_edw