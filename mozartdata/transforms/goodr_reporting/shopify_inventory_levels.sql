WITH 
grid_days as
(
  select 
    DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY NULL), CURRENT_DATE()) AS date
  FROM TABLE(GENERATOR(ROWCOUNT => 90))
  order by date 
)
, grid_product as
(
  select
    p.item_id_ns
  , p.inventory_item_id_d2c_shopify
  , d.date
  from
    dim.product p
  inner join
    goodr_reporting.launch_date_vs_earliest_sale ld
    on p.item_id_ns = ld.item_id_ns
    and earliest_d2c_sale >= dateadd(day, -120, current_date())
  inner join
    grid_days d
  on 1=1
)
, final_available as
(
SELECT
  inventory_item_id as inventory_item_id_d2c_shopify
, il.available
, date(il.updated_at) last_updated_date
FROM
  shopify.inventory_level il
)
, sales as
(
  SELECT
    p.inventory_item_id_d2c_shopify
  , p.display_name
  , ol.order_created_date_pst as sold_date
  , sum(oi.quantity_sold) quantity
  FROM
    fact.shopify_order_item oi
  INNER JOIN
    dim.product p
  ON p.product_id_edw = oi.product_id_edw
  INNER JOIN
    fact.shopify_order_line ol
    on oi.order_id_shopify = ol.order_id_shopify
  -- INNER JOIN
  --   fact.orders o
  -- ON do.order_id_edw = o.order_id_edw
   and ol.store = 'Goodr.com'
  GROUP BY
    p.inventory_item_id_d2c_shopify
  , ol.order_created_date_pst
  , p.display_name
)
, rolling_quantity as
(
SELECT
    gp.inventory_item_id_d2c_shopify
  , gp.date
  , s.display_name
  , coalesce(s.quantity,0) as quantity_sold
  , SUM(coalesce(s.quantity,0)) OVER (PARTITION BY gp.inventory_item_id_d2c_shopify ORDER BY gp.date desc) AS rolling_sum
FROM
  grid_product gp
LEFT JOIN
  sales s
  on gp.inventory_item_id_d2c_shopify = s.inventory_item_id_d2c_shopify
  and gp.date = s.sold_date
WHERE
   gp.inventory_item_id_d2c_shopify =42198683254842 
  order by date desc
)
SELECT
  rq.inventory_item_id_d2c_shopify
, rq.display_name
, rq.date
, rq.quantity_sold
, rolling_sum + fa.available as ending_quantity
FROM
  rolling_quantity rq
INNER JOIN
  final_available fa
  ON rq.inventory_item_id_d2c_shopify = fa.inventory_item_id_d2c_shopify
ORDER BY
  rq.inventory_item_id_d2c_shopify
, rq.date desc
  
  -- select * from sales where inventory_item_id_d2c_shopify =41762839756858 order by sold_date

--   SELECT DISTINCT
--     p.inventory_item_id_d2c_shopify
--   , ol.order_created_date as sold_date
--   , ol.order_id_shopify
--   , p.display_name
--   FROM
--     fact.shopify_order_item oi
--   INNER JOIN
--     dim.product p
--   ON p.product_id_edw = oi.product_id_edw
--   INNER JOIN
--     fact.shopify_order_line ol
--     on oi.order_id_shopify = ol.order_id_shopify
--  where inventory_item_id_d2c_shopify =41762839756858
--   and ol.store = 'Goodr.com'
-- and ol.order_created_date_pst = '2023-03-10'
--   order by ol.order_id_shopify


-- select ol.order_created_date, ol.order_created_timestamp, ol.order_created_timestamp_pst, oi.* 
-- from fact.shopify_order_item oi 
--   inner join fact.shopify_order_line ol on oi.order_id_shopify = ol.order_id_shopify 
--   where oi.order_id_shopify = '4698051280954'

--   select * from fact.shopify_order_line where order_id_shopify = '4698693828666'
  
--   select * from fact.shopify_order_line ol where order_created_date = '2023-10-10'


-- SELECT
--   il.*
-- FROM
--   shopify.inventory_level il
-- WHERE
--   il.inventory_item_id = 41762839756858

-- select * from dim.product where display_name = '24 Carrot Sunnies'

-- select * from shopify.product_variant where sku = 'G00208-VRG-GR1-RF' --41762839756858

-- select * from shopify.inventory_item where sku = 'G00208-VRG-GR1-RF'