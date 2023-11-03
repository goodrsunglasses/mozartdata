WITH launch_orders as
  (
    SELECT
      oi.order_id_edw
    , o.order_date_pst
    , p.display_name
    , p.collection
    , p.family
    , MIN(oid.transaction_date_pst) AS earliest_sale
    , sum(oi.amount_sold) launch_product_sales
    , sum(oi.quantity_sold) launch_product_quantity
    from
      fact.order_item oi
    inner join
      draft_dim.product p
      on p.item_id_ns = oi.item_id_ns
    inner join
      fact.orders o
      on oi.order_id_edw = o.order_id_edw
      and o.channel = 'Goodr.com'
    inner join 
      fact.order_item_detail oid 
      on oi.order_id_edw = oid.order_id_edw
    group by
      oi.order_id_edw
    , p.display_name
    , p.collection
    , p.family
    , o.order_date_pst
  )
SELECT
  lo.display_name,
  o.order_date_pst,
  lo.collection,
  lo.family,
  lo.earliest_sale,
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
WHERE lo.earliest_sale >= '2023-01-01' and o.order_date_pst >= '2023-01-01'
group by lo.display_name, lo.family, lo.collection, o.order_date_pst, lo.earliest_sale