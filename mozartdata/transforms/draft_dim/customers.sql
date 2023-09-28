/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per customer. This table considers retailers as one customer.
This transform creates a customer dimension that combines shopify, netsuite and zendesk information together to give a full picture of our customers.

joins: 
Full join for shopify and netsuite, left join for zendesk all on the email.

aliases: 
ns = netsuite
shop = shopify
cust = customer

*/
SELECT
  staging_customer.email,
  customer_category,
  customer_id_edw,
  prospect_flag,
  coalesce((shop_customer.first_name || ' ' || shop_customer.last_name),(specialty_shopify.first_name || ' ' || specialty_shopify.last_name),(ns_cust.altname))
FROM
  staging.dim_customer staging_customer
  LEFT OUTER JOIN shopify.customer shop_customer ON shop_customer.email = staging_customer.email
  LEFT OUTER JOIN specialty_shopify.customer specialty_shopify ON specialty_shopify.email = staging_customer.email
left outer join netsuite.customer ns_cust on ns_cust.email = staging_customer.email
order by email desc