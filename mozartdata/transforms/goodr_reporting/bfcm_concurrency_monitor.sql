SELECT
  ord.order_id_edw,
  shop.store,
  shop.order_created_timestamp_pst,
  shop.financial_status,
  shop.fulfillment_status
FROM
  dim.orders ord 
  left outer join fact.shopify_orders shop on shop.order_id_shopify = ord.order_id_shopify

select  from fact.shopify_orders