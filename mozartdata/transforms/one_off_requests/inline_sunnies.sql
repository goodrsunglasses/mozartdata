--dim.product where family = 'INLINE' and merchandise_department = 'SUNGLASSES'
with customer_orders
(
  SELECT
    o.order_id_edw
  , o.customer_id_edw
  , o.sold_date
  , row_number() over (partition by o.customer_id_edw order by o.sold_date)
  FROM
    fact.orders o
  WHERE
    o.channel = 'Goodr.com'
),
sunnies as
(
  SELECT
    oi.order_id_edw
  , p.sku
  , p.display_name
  , sum(oi.quantity_sold)
  FROM
    fact.order_item oi
  INNER JOIN
    fact.orders o
    on oi.order_id_edw = o.order_id_edw
  INNER JOIN
    dim.product p
    on oi.product_id_edw = p.product_id_edw
  WHERE
    p.merchandise_department = 'SUNGLASSES'
  and o.channel = 'Goodr.com'
  GROUP BY
    oi.order_id_edw
  , p.sku
  , p.name
  ORDER BY
    oi.order_id_edw
  
)