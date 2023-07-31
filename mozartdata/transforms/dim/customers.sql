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
  ns_cust.id AS ns_cust_id, --Netsuite customer ID
  ns_cust.entityid AS ns_entity_id, --Netsuite customer realtext ID
  ns_cust.altname AS ns_altname, --Netsuite customer Full Name
  ns_cust.defaultbillingaddress AS ns_defaultbillingaddressid, --- billing address id
  ns_cust.category AS ns_cust_channel, --Customer sales channel
  ns_cust.isperson AS ns_cust_type, --Boolean to determine if customer is Company or Individual
  ns_cust.entitystatus AS ns_entitystatus, --Netsuite customer Status (WON open, Closed...)
  ns_cust.lastmodifieddate AS ns_cust_last_modified_date, --Netsuite customer last modified date, not sure what this is specfically supposed to be yet
  ns_cust.email AS ns_cust_email, --Netsuite customer email, used to join to shopify
  shop_cust.id AS shop_cust_id, --- joined on email
  shop_cust.email AS shop_cust_email, -- Shopify customer email, there just in case there are people who made shopify accounts but didn't order
  ns_cust.defaultshippingaddress, --shipping address id
  first_value (ns_tran.trandate) OVER (
    PARTITION BY
      ns_cust.id
    ORDER BY
      ns_tran.trandate asc
  ) NS_Cust_first_order_date, --These 4 next window functions are simply finding the first/last dates and order IDS in an ordered list of a given customer id's orders, sorted by transaction date ascending
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
  ns_cust.companyname, --NS company name if applicable,
  ns_cust_category.name ns_cust_channel,--NS customer channel they are a part of (sellgoodr,goodr.com,CS,EMP...),
  CASE
    WHEN ns_cust_type = 'T' THEN 'Individual'
    ELSE 'Company'
  END AS ns_cust_category_name --Simple case when to display if the customer is a company or an individual using isperson
FROM
  netsuite.customer ns_cust
  FULL JOIN shopify.customer shop_cust ON shop_cust.email = ns_cust.email
  LEFT OUTER JOIN netsuite.transaction ns_tran ON ns_tran.entity = ns_cust.id
  LEFT OUTER JOIN netsuite.customerCategory ns_cust_category ON ns_cust.category = ns_cust_category.id