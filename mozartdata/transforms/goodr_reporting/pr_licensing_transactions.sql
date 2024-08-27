SELECT
  shop.order_id_edw,
  shop.store,
  shop.sku as shopsku,
  shop.name shopname,
  shop.rate shoprate,
  prod.family,
  prod.stage,
  prod.merchandise_class,
  prod.design_tier
FROM
  fact.shopify_order_item shop
left outer join dim.product prod on prod.sku = shop.sku