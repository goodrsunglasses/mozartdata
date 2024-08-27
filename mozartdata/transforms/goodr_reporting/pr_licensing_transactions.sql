SELECT
  shop.order_id_edw,
  shop.store,
  shop.sku,
  shop.name,
  shop.rate,
  prod.*
FROM
  fact.shopify_order_item shop
left outer join dim.product prod on prod.sku = shop.sku