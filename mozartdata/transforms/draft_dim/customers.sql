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
  *
FROM
  staging.dim_customer