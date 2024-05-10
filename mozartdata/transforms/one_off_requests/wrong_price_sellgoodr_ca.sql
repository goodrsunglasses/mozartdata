SELECT 
  o.id, 
  o.email,
  o.name,
  o.shipping_address_name,
  o.shipping_address_first_name, 
  o.shipping_address_last_name,
  o.shipping_address_company,
  o.shipping_address_phone,
  o.billing_address_name,
  o.billing_address_first_name, 
  o.billing_address_last_name,
  o.billing_address_company,
  o.billing_address_phone,
  o.fulfillment_status,
  o.processed_at,
  o.total_price,
  oi.name as item,
  oi.price as price_of_item
  
FROM sellgoodr_canada_shopify.order_line oi
  join sellgoodr_canada_shopify."ORDER" o on oi.order_id = o.id
where oi.name in (
    'Road Twerk Ahead',
    'The Empire Did Nothing Wrong', 
    'Not a Phase, a Transformation', 
    'Dinner Mint Debauchery', 
    'Drinks Seawater, Sees Future',   
    'Face Under Construction', 
    'Warn To Be Wild')
  or oi.name like '%Queer%'
  or oi.name like '%Blush%'
  or oi.name like '%Calamity%'