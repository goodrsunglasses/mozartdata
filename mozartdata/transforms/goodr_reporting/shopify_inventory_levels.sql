SELECT
  il.available
, p.*
FROM
  shopify.inventory_level il
LEFT JOIN
  dim.product p
  on p.inventory_item_id_d2c_shopify = il.inventory_item_id
WHERE
  p.display_name = '24 Carrot Sunnies'

SELECT
  il.*
FROM
  shopify.inventory_level il
WHERE
  il.inventory_item_id = 41762839756858

select * from dim.product where display_name = '24 Carrot Sunnies'

select * from shopify.product_variant where sku = 'G00208-VRG-GR1-RF' --41762839756858

select * from shopify.inventory_item where sku = 'G00208-VRG-GR1-RF'