SELECT ct.*, c.email, ca.company FROM specialty_shopify.customer_tag ct
  left join  specialty_shopify.customer c on ct.customer_id = c.id
  left join specialty_shopify.customer_address ca on ct.customer_id = ca.customer_id
  where value in ('run', 'golf', 'bike', 'beast', 'summit', 'snow', 'sportsball')