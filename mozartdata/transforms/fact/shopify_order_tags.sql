/*
Purpose: show tags from Shopify orders on goodr.com and sellgoodr.com.
One row per tag per order.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
SELECT
  concat(id,'_',index) as order_tag_id_edw,
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
UNION ALL
SELECT
  concat(id,'_',index) as order_tag_id_edw,
  name AS order_id_edw,
  id AS order_id_shopify,
  tags.index,
  tags.value
FROM
  specialty_shopify."ORDER" b2b_shop
  LEFT OUTER JOIN specialty_shopify.order_tag tags ON tags.order_id = b2b_shop.id
  --Just to ignore when there is no tag, because the table starts with the shopify orders just to get the order_id_edw
WHERE
  value IS NOT NULL
ORDER BY
  order_id_edw