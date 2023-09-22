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
  ),
  aggregate_ns AS (
    SELECT DISTINCT
      cust_ns.id as cust_id_ns,
      FIRST_VALUE(tran_ns.trandate) OVER (
        PARTITION BY
          cust_ns.id
        ORDER BY
          tran_ns.trandate asc
      ) first_order_date,
      FIRST_VALUE(tran_ns.id) OVER (
        PARTITION BY
          cust_ns.id
        ORDER BY
          tran_ns.trandate asc
      ) first_order_id_ns,
      LAST_VALUE(tran_ns.id) OVER (
        PARTITION BY
          cust_ns.id
        ORDER BY
          tran_ns.trandate asc
      ) most_recent_order_id_ns,
      LAST_VALUE(tran_ns.trandate) OVER (
        PARTITION BY
          cust_ns.id
        ORDER BY
          tran_ns.trandate asc
      ) most_recent_order_date,
      COUNT(DISTINCT tran_ns.custbody_goodr_shopify_order) OVER (
        PARTITION BY
          cust_ns.id
      ) AS order_count,
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
      END AS is_key_account_current -- case when to determine if its in the list of key account customers, for later reporting and filtering
    FROM
      netsuite.customer cust_ns
  LEFT OUTER JOIN netsuite.transaction tran_ns ON tran_ns.entity = cust_ns.id
  )
SELECT DISTINCT
  COALESCE(MD5(cust_ns.email), MD5(cust_shop.email)) AS goodr_customer_id,
  cust_ns.id AS cust_id_ns, --Netsuite customer ID
  cust_ns.entityid AS entity_id_ns, --Netsuite customer realtext ID
  cust_ns.category AS channel_id_ns, --Customer sales channel
  cust_ns.entitystatus AS status_id_ns, --Netsuite customer Status (WON open, Closed...)
  cust_ns.defaultbillingaddress AS address_billing_default_id_ns, --- billing address id
  cust_ns.defaultshippingaddress AS address_shipping_default_id_ns, --shipping address id
  cust_shop.id AS cust_id_shop, --- joined on email
  requester_id AS cust_id_zendesk,
  cust_ns.altname AS name_full, --Netsuite customer Full Name
  cust_ns.lastmodifieddate AS last_modified_date, --Netsuite customer last modified date, not sure what this is specfically supposed to be yet
  COALESCE(cust_ns.email, cust_shop.email) AS email,
  ticket_count, --count of zendesk tickets
  --These 4 next window functions are finding the first/last dates and order IDS in an ordered list of a given customer id's orders, sorted by transaction date ascending
  cust_ns.companyname AS company_name, --NS company name if applicable,
  cust_category_ns.name channel, --NS customer channel they are a part of (sellgoodr,goodr.com,CS,EMP...),
  CASE
    WHEN cust_ns.isperson = 'T' THEN 'Individual'
    ELSE 'Company'
  END AS is_person, --case when to display if the customer is a company or an individual using isperson
  first_order_date,
  first_order_id_ns,
  most_recent_order_id_ns,
  most_recent_order_date,
  order_count,
  is_key_account_current
FROM
  netsuite.customer cust_ns
  left outer join aggregate_ns on aggregate_ns.cust_id_ns = cust_ns.id
  FULL JOIN shopify.customer cust_shop ON cust_shop.email = cust_ns.email
  LEFT OUTER JOIN netsuite.transaction tran_ns ON tran_ns.entity = cust_ns.id
  LEFT OUTER JOIN netsuite.customerCategory cust_category_ns ON cust_ns.category = cust_category_ns.id
  LEFT OUTER JOIN users_zendesk ON users_zendesk.email = cust_ns.email