--- shopify shipping method by order Aug 15 - today

SELECT
  so.*,
  ship.id as shipment_id,
  ship.code
FROM
 shopify."ORDER" so 
  LEFT JOIN shopify.order_shipping_line ship ON so.id = ship.order_id 
where created_at >= '2024-08-15'


-----------
--select * from fact.shopify_orders
--select * from shopify."ORDER"   where name = 'G2589792'
--    select * from shopify.order_shipping_line 
---------- QC
--select count(*) from shopify.order_shipping_line where _fivetran_synced >= '2024-08-15'   ---379749
--select count(*) from  shopify."ORDER" where _fivetran_synced >= '2024-08-15'  --389523