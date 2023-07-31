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
SELECT DISTINCT
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
  shop_cust.id AS shop_cust_id, --- joined on email
  shop_cust.email AS shop_cust_email,
  ns_cust.defaultshippingaddress,
  first_value (ns_tran.trandate) OVER (
    PARTITION BY
      ns_cust.id
    ORDER BY
      ns_tran.trandate asc
  ) NS_Cust_first_order_date,
  first_value (ns_tran.id) OVER (
    PARTITION BY
      ns_cust.id
    ORDER BY
      ns_tran.trandate asc
  ) NS_Cust_first_order_id,
  last_value (ns_tran.id) OVER (
    PARTITION BY
      ns_cust.id
    ORDER BY
      ns_tran.trandate asc
  ) NS_Cust_most_recent_order_id,
  last_value (ns_tran.trandate) OVER (
    PARTITION BY
      ns_cust.id
    ORDER BY
      ns_tran.trandate asc
  ) NS_Cust_most_recent_order_date,
  COUNT(ns_tran.trandate) OVER (
    PARTITION BY
      ns_cust.id
  ) AS ns_order_count,
  ns_cust.companyname,
  ns_cust_category.name ns_cust_channel,
  CASE
    WHEN ns_cust_type = 'T' THEN 'Individual'
    ELSE 'Company'
  END AS ns_cust_category_name
  --- channel
FROM
  netsuite.customer ns_cust
  FULL JOIN shopify.customer shop_cust ON shop_cust.email = ns_cust.email
  LEFT OUTER JOIN netsuite.transaction ns_tran ON ns_tran.entity = ns_cust.id
  LEFT OUTER JOIN netsuite.customerCategory ns_cust_category ON ns_cust.category = ns_cust_category.id
limit 1000;