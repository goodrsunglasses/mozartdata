SELECT
  name AS order_id_edw,
  id AS order_id_shopify,
  tags.index,
  tags.value
FROM
  shopify."ORDER" d2c_shop
  LEFT OUTER JOIN shopify.order_tag tags ON tags.order_id = d2c_shop.id
--Just to ignore when there is no tag, because the table starts with the shopify orders just to get the order_id_edw
WHERE
  value IS NOT NULL
ORDER BY
  order_id_edw