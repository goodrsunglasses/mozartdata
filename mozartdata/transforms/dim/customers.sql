/*
purpose:
One row per customer.
This transform creates the customer dimension by combining data from netsuite and shopify.

joins: ns and shop on email

aliases: 
ns = netsuite
shop = shopify
cust = customer
*/

SELECT
  ns_cust.id AS ns_cust_id,
  ns_cust.entityid AS ns_entity_id,
  ns_cust.altname AS ns_altname,
  ns_cust.defaultbillingaddress AS ns_defaultbillingaddressid, --- billing address id
  ns_cust.category AS ns_cust_category, --Determines if customer is company or not
  ns_cust.isperson AS ns_cust_type, --boolean to also determine customer type?
  ns_cust.entitystatus AS ns_entitystatus,
  ns_cust.lastmodifieddate AS ns_cust_last_modified_date,
  ns_cust.email AS ns_cust_email,
  --- ns customer lead status - what does this mean? .... there is a field in NS front end that was labeled "lead status" (closed, etc)
  shop_cust.id as shop_cust_id, --- joined on email
  shop_cust.email as shop_cust_email,
  ns_cust.defaultshippingaddress
  --- channel
FROM
  netsuite.customer ns_cust
FULL JOIN shopify.customer shop_cust on shop_cust.email = ns_cust.email
where ns_cust_category is not null