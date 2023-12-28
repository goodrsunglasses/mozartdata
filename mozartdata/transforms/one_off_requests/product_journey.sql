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
      p.sku IN ('G00288-OG-GD7-RF')  
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
  )

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
, o.total_quantity_sold
from
  product_list pl
left join
  po
  on po.product_id_edw = pl.product_id_edw
left join
  orders o
  on o.product_id_edw = pl.product_id_edw