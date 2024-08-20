SELECT
  oi.order_id_ns,
  oi.sku,
  oi.plain_name,
    oi.quantity_booked,
  oi.quantity_sold,
    oi.quantity_fulfilled,
  prod.merchandise_class,
  c.id as shopify_customer_id, 
  c.email
FROM
  fact.order_item oi
  LEFT JOIN dim.product prod ON prod.product_id_edw = oi.product_id_edw
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
  left join fact.customer_shopify_map c on oi.customer_id_edw = c.customer_id_edw
WHERE
  o.channel = 'Specialty'
AND prod.merchandise_class IN ('ASTRO GS', 'ASTRO GS', 'BUG GS')