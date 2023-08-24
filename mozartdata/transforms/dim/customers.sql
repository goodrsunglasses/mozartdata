/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per customer. This table considers retailers as one customer.
This transform creates a customer dimension that combines shopify, netsuite and zendesk information together to give a full picture of our customers.

joins: 

aliases: 
ns = netsuite
shop = shopify
cust = customer

*/

WITH
  users_zendesk AS (
    SELECT DISTINCT
      email,
      requester_id,
      COUNT(ticket.id) OVER (
        PARTITION BY
          email
      ) AS ticket_count
    FROM
      zendesk.ticket ticket
      LEFT OUTER JOIN zendesk.user USER ON USER.id = ticket.requester_id
  )
SELECT DISTINCT
  MD5(cust_ns.email) AS goodr_customer_id,
  cust_ns.id AS cust_id_ns, --Netsuite customer ID
  cust_ns.entityid AS entity_id_ns, --Netsuite customer realtext ID
  cust_ns.altname AS altname, --Netsuite customer Full Name
  cust_ns.defaultbillingaddress AS defaultbillingaddressid, --- billing address id
  cust_ns.category AS cust_channel, --Customer sales channel
  cust_ns.isperson AS cust_type_ns, --Boolean to determine if customer is Company or Individual
  cust_ns.entitystatus AS entitystatus, --Netsuite customer Status (WON open, Closed...)
  cust_ns.lastmodifieddate AS cust_last_modified_date, --Netsuite customer last modified date, not sure what this is specfically supposed to be yet
  cust_ns.email AS cust_email, --Netsuite customer email, used to join to shopify
  cust_shop.id AS cust_id_shop_ns, --- joined on email
  cust_shop.email AS cust_email_shop, -- Shopify customer email, there just in case there are people who made shopify accounts but didn't order
  cust_ns.defaultshippingaddress, --shipping address id
  requester_id AS cust_id_zendesk,
  ticket_count,
  FIRST_VALUE(tran_ns.trandate) OVER (
    PARTITION BY
      cust_ns.id
    ORDER BY
      tran_ns.trandate asc
  ) Cust_first_order_date_ns, --These 4 next window functions are simply finding the first/last dates and order IDS in an ordered list of a given customer id's orders, sorted by transaction date ascending
  FIRST_VALUE(tran_ns.id) OVER (
    PARTITION BY
      cust_ns.id
    ORDER BY
      tran_ns.trandate asc
  ) cust_ns_first_order_id,
  LAST_VALUE(tran_ns.id) OVER (
    PARTITION BY
      cust_ns.id
    ORDER BY
      tran_ns.trandate asc
  ) Cust_most_recent_order_id_ns,
  LAST_VALUE(tran_ns.trandate) OVER (
    PARTITION BY
      cust_ns.id
    ORDER BY
      tran_ns.trandate asc
  ) Cust_most_recent_order_date_ns,
  COUNT(tran_ns.trandate) OVER (
    PARTITION BY
      cust_ns.id
  ) AS order_count_ns,
  cust_ns.companyname, --NS company name if applicable,
  cust_category_ns.name cust_channel_name_ns, --NS customer channel they are a part of (sellgoodr,goodr.com,CS,EMP...),
  CASE
    WHEN cust_type_ns = 'T' THEN 'Individual'
    ELSE 'Company'
  END AS cust_category_name_ns, --Simple case when to display if the customer is a company or an individual using isperson
  CASE
    WHEN cust_id_ns IN (
      12489,
      479,
      465,
      476,
      8147,
      73200,
      3363588,
      8169,
      3633497,
      3682848,
      467,
      466,
      2510,
      478,
      475,
      4484902,
      4533439
    ) THEN TRUE
    ELSE FALSE
  END AS is_key_account -- case when to determine if its in the list of key account customers, for later reporting and filtering
FROM
  netsuite.customer cust_ns
  FULL JOIN shopify.customer cust_shop ON cust_shop.email = cust_ns.email
  LEFT OUTER JOIN netsuite.transaction tran_ns ON tran_ns.entity = cust_ns.id
  LEFT OUTER JOIN netsuite.customerCategory cust_category_ns ON cust_ns.category = cust_category_ns.id
  LEFT OUTER JOIN users_zendesk ON users_zendesk.email = cust_ns.email