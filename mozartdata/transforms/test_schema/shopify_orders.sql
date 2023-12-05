SELECT 
ol.*,
o.created_at,
o.order_number
FROM shopify.order_line ol
left join shopify."ORDER" o 
WHERE o.created_at between '2023-11-27' and '2023-12-1'