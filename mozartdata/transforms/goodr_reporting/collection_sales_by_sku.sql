WITH 
grid_date AS (
  SELECT 
    date 
  FROM 
    dim.date
  WHERE 
    date >= '2022-01-01' AND date <= '2025-01-01'
),
grid_product AS (
  SELECT
    p.item_id_ns,
    d.date
  FROM
    dim.product p
  CROSS JOIN
    grid_date d
  WHERE 
    p.item_id_ns IS NOT NULL
    AND p.family = 'LICENSING' 
    AND p.replenish_flag = 'True'
),
collection_orders AS (
  SELECT
    oi.order_id_edw,
    oi.item_id_ns,
    o.sold_date,
    p.family as product_category,
    SUM(oi.amount_product_sold) AS collection_product_sales,
    SUM(oi.quantity_sold) AS collection_product_quantity
  FROM 
    fact.order_item oi
  INNER JOIN 
    fact.orders o ON oi.order_id_edw = o.order_id_edw
  LEFT JOIN 
    dim.product p ON p.item_id_ns = oi.item_id_ns
  WHERE 
    o.channel = 'Goodr.com'
    AND p.family = 'LICENSING' 
    AND o.sold_date >= '2022-01-01'
    AND p.replenish_flag = 'True'
  GROUP BY
    oi.order_id_edw,
    oi.item_id_ns,
    p.family,
    o.sold_date
),
total_sales AS (
  SELECT
    co.item_id_ns,
    co.sold_date,
    SUM(co.collection_product_sales) AS collection_product_sales,
    SUM(co.collection_product_quantity) AS collection_product_quantity,
    SUM(o.amount_product_sold) AS total_sales,
    SUM(o.quantity_sold) AS total_quantity,
    COUNT(DISTINCT o.order_id_edw) AS orders_containing_collection
  FROM
    collection_orders co
  INNER JOIN 
    fact.orders o ON co.order_id_edw = o.order_id_edw
  WHERE 
    o.sold_date >= '2022-01-01'
  GROUP BY
    co.item_id_ns, 
    co.sold_date
)

SELECT
  gp.date,
  gp.item_id_ns,
  p.display_name,
  p.collection,
  p.family,
  p.sku,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  COALESCE(ts.collection_product_sales, 0) AS collection_product_sales,
  COALESCE(ts.collection_product_quantity, 0) AS collection_product_quantity,
  COALESCE(ts.total_sales, 0) AS total_sales,
  COALESCE(ts.total_quantity, 0) AS total_quantity,
  COALESCE(ts.orders_containing_collection, 0) AS orders_containing_collection
FROM 
  grid_product gp
INNER JOIN 
  dim.product p ON gp.item_id_ns = p.item_id_ns
LEFT JOIN 
  total_sales ts ON gp.item_id_ns = ts.item_id_ns AND gp.date = ts.sold_date
WHERE 
  p.merchandise_department = 'SUNGLASSES'
ORDER BY 
  gp.item_id_ns, 
  gp.date;