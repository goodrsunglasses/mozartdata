--goodr .com
SELECT
  tt.*,
  o.name,
  o.created_at
FROM
  shopify.tender_transaction tt
  LEFT JOIN shopify."ORDER" o ON o.id = tt.order_id
WHERE
  tt.processed_at > '2024-03-24'

--sg
SELECT tt.*, o.name, o.created_at
FROM specialty_shopify.tender_transaction tt
  left join specialty_shopify."ORDER" o on o.id = tt.order_id
where tt.processed_at > '2024-03-24'


-- goodr ca
SELECT tt.*, o.name, o.created_at
FROM goodr_canada_shopify.tender_transaction tt
  left join goodr_canada_shopify."ORDER" o on o.id = tt.order_id
where tt.processed_at > '2024-03-24'


--sg ca
SELECT tt.*, o.name, o.created_at
FROM sellgoodr_canada_shopify.tender_transaction tt
  left join sellgoodr_canada_shopify."ORDER" o on o.id = tt.order_id
where tt.processed_at > '2024-03-24'