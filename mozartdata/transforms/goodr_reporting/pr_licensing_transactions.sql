--Gonna have to rework off of dim.orders and join to the respective tables so that I can make sure it will show both orders only in shopify and ones only in NS, so grab some samples from both

SELECT
  shop.order_id_edw order_id_shopify,
  shop.store,
  shop.sku as shopsku,
  shop.name shopname,
  shop.rate as product_rate,
  shop.quantity_booked as quantity_booked_shopify,
  shop.amount_sold amount_sol,
  prod.family,
  prod.stage,
  prod.merchandise_class,
  prod.design_tier,
  ord.quantity_booked,
  ord.rate_booked,
  
FROM
  fact.shopify_order_item shop
left outer join dim.product prod on prod.sku = shop.sku
left outer join fact.order_item ord on (ord.sku = shop.sku and ord.order_id_edw = shop.order_id_edw)
where customer_id_edw is not null