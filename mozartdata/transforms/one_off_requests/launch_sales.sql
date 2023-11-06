WITH
  collection_cte AS (
    SELECT
      item_id_ns,
      sku,
      CASE
        WHEN sku IN ('G00237-OG-LB1-RF', 'G00273-OG-RS2-RF') THEN 'RUN CHICAGO + DC'
        WHEN sku IN (
          'G00252-OG-BO1-RF',
          'G00253-OG-GD6-RF',
          'G00254-OG-GD7-RF'
        ) THEN 'DAZED & CONFUSED'
        WHEN sku IN ('G00287-OG-BK1-NR') THEN 'EXERCISE THE DEMONS'
        WHEN sku IN ('G00274-OG-BK1-GR') THEN 'RUN NYC'
        WHEN sku IN ('G00264-OG-LLB2-RF') THEN 'BREAKING SILENCE'
        WHEN sku IN ('G00296-OG-GR1-GR', 'G00297-OG-BR1-NR') THEN 'MONSTERS'
        ELSE NULL
      END AS custom_collection,
      case
      when custom_collection = 'RUN CHICAGO + DC' then '2023-09-12'
      when custom_collection = 'DAZED & CONFUSED' then '2023-09-16'
      when custom_collection = 'EXERCISE THE DEMONS' then '2023-10-03'
      when custom_collection = 'BREAKING SILENCE' then '2023-10-06'
      when custom_collection = 'RUN NYC' then '2023-10-10'
      when custom_collection = 'MONSTERS' then '2023-10-13'
      end launch_date,
      max(launch_date) over (partition by custom_collection) latest_launch_date
    FROM
      dim.product
  
  ),
launch_orders as
  (
    SELECT
      oi.order_id_edw
    , cc.custom_collection
    , row_number() over (partition by oi.order_id_edw order by latest_launch_date desc)rn
    , count(distinct cc.custom_collection) unique_collections
    , sum(oi.amount_sold) launch_product_sales
    , sum(oi.quantity_sold) launch_product_quantity
    from
      fact.order_item oi
    inner join
      collection_cte cc
      on cc.item_id_ns = oi.item_id_ns
      and custom_collection is not null
    inner join
      fact.orders o
      on oi.order_id_edw = o.order_id_edw
      and o.channel = 'Goodr.com'
    where cc.custom_collection is not null
    group by
      oi.order_id_edw
    , cc.custom_collection
    , cc.latest_launch_date
  )
SELECT
  lo.custom_collection,
  sum(lo.launch_product_sales) as launch_product_sales,
  sum(lo.launch_product_quantity) as launch_product_quantity,
  SUM(o.amount_sold) total_sales,
  SUM(o.quantity_sold) total_quantity,
  COUNT(DISTINCT o.order_id_edw) as orders_containing_colleciton
FROM
 fact.orders o 
  inner join
    launch_orders lo
  on o.order_id_edw = lo.order_id_edw
  -- left JOIN collection_cte cc ON cc.item_id_ns = oi.item_id_ns
where
  rn=1
GROUP BY
  lo.custom_collection
ORDER BY
  lo.custom_collection