with staging as
(
 SELECT
   s.productid                                                 AS item_id_shipstation
 , s.sku
 , s.createdate as created_timestamp
 , RANK() OVER (PARTITION BY s.sku ORDER BY s.createdate DESC) AS created_order
 FROM
   shipstation_portable.shipstation_products_8589936627 s
 )
SELECT
  s.item_id_shipstation
, s.sku
, s.created_timestamp
, case when s.created_order = 1 then true else false end primary_item_id
, case when max(created_order) over (PARTITION BY s.sku) > 1 then true else false end multiple_id_flag
FROM
  staging s