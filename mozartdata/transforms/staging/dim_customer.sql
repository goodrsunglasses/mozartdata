/*
THIS TRANSFORM IS IN PROGRESS, DO NOT USE YET
purpose: 
One row per customer and category (B2B, D2C).
This transform creates a staging table which creates customer_id_edw for every customer in our various source systems (NetSuite, Shopify...)

We will use channel in NetSuite to determine categories, but also use the shopify store (goodr.com/sellgoodr) to differentiate between D2C and B2B customers.

joins: 


aliases: 
ns = netsuite
shop = shopify
cust = customer
custbody_goodr_shopify_order = order_num (this is the shopify order number, and is pulled into NS using the custom field custbody_goodr_shopify_order)

*/
/*
The "ns" CTE pulls emails and customer categories based on order channel in netsuite. The channels come from dim.orders and the classification has been approved. 
A single customer MAY be in multiple categories. ex. someone who works for a specialty store also uses their work email to place an order on goodr.com
We have to lowercase the email, otherwise we would get different emails based on capitalization, which doesn't truly differentiate emails.
aliases: 
t = netsuite.transaction
c = netsuite.customer
channel = netsuite.customrecord_cseg7
*/

with ns as
  (
SELECT distinct
  lower(c.email) email
, CASE
    WHEN channel.name IN (
      'Specialty',
      'Key Account',
      'Global',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'B2B'
    WHEN channel.name IN (
      'Goodr.com',
      'Amazon',
      'Cabana',
      'Goodr.com CAN',
      'Prescription'
    ) THEN 'D2C'
    WHEN channel.name IN (
      'Goodrwill.com',
      'Customer Service CAN',
      'Marketing',
      'Customer Service'
    ) THEN 'INDIRECT'
  END AS  customer_category
FROM
  netsuite.transaction t
inner join
  netsuite.customer c
  on t.entity = c.id
  LEFT OUTER JOIN 
  netsuite.customrecord_cseg7 channel
  on channel.id = t.cseg7
where
  t.recordtype in ('salesorder','cashsale','invoice')
order by
  email
)
/*
The "d2c_shop" CTE pulls emails and customer categories based on shopify store from goodr.com shopify. All goodr.com sales are considered D2C
aliases: 
  none
*/
, d2c_shop as
(
  SELECT distinct
    lower(email) email
  , 'D2C' as customer_category
  from
    shopify.customer
  )
, b2b_shop as
(
  SELECT distinct
    lower(email) email
  , 'B2B' as customer_category
 -- , 'specialty' as source
  from
    specialty_shopify.customer
  )
, d2c_prospect as
  (select 
    a.email
  , case when b.email is null then 1 else 0 end prospect_flag
  FROM
    d2c_shop a
  left join
    ns b
  on a.email = b.email
  and b.customer_category = 'D2C')
, b2b_prospect as
  (select 
    a.email
  , case when b.email is null then 1 else 0 end prospect_flag
  FROM
    b2b_shop a
  left join
    ns b
  on a.email = b.email
  and b.customer_category = 'B2B')
 , unions as
  (
  SELECT distinct
    *
  from
    ns a
  union all select * from d2c_shop
  union all select * from b2b_shop
  ) 
  select distinct
    a.email
  , a.customer_category
  , md5(concat(a.email, '::', a.customer_category)) customer_id_edw
  , coalesce(b.prospect_flag,c.prospect_flag,0) prospect_flag
  from
    unions a
  left join
    d2c_prospect b
    on a.email = b.email
    and a.customer_category = 'D2C'
  left join
    b2b_prospect c
    on a.email = c.email
    and a.customer_category = 'B2B'
order by
  email

--select * from specialty_shopify.customer where email = 'Andy@golfballs.com'

  /*
select email, channel.name from netsuite.transaction t
  LEFT OUTER JOIN 
  netsuite.customrecord_cseg7 channel
  on channel.id = t.cseg7
  where t.email in (select email from final where prospect_flag = true and customer_category = 'D2C')

select * from ns where email = 'sjones1@tarleton.edu'
--select * from netsuite.transaction t where email = 'katiewright0110@gmail.com'
*/