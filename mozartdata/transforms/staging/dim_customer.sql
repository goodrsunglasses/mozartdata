/*
THIS TRANSFORM IS IN PROGRESS, DO NOT USE YET
purpose: 
One row per customer and category (B2B, D2C). ie. one row per MD5
This transform creates a staging table which creates customer_id_edw for every customer in our various source systems (NetSuite, Shopify...)

We will use channel in NetSuite to determine categories, but also use the shopify store (goodr.com/sellgoodr) to differentiate between D2C and B2B customers.

We have to lowercase the email addresses, otherwise we would get different emails based on capitalization, which doesn't truly differentiate emails/customers.

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

aliases: 
t = netsuite.transaction
c = netsuite.customer
channel = netsuite.customrecord_cseg7
*/

with ns as
  (
SELECT distinct
  lower(case when c.id= 1836849 then t.email else c.email end) email
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
)
/*
The "d2c_shopify" CTE pulls emails and customer categories based on shopify store from goodr.com shopify. All goodr.com sales are considered D2C
aliases: 
  none
*/
, d2c_shopify as
(
  SELECT distinct
    lower(email) email
  , 'D2C' as customer_category
  from
    shopify.customer
  )
/*
The "b2b_shopify" CTE pulls emails and customer categories based on shopify store from sellgoodr shopify. All sellgoodr sales are considered B2B
aliases: 
  none
*/
, b2b_shopify as
(
  SELECT distinct
    lower(email) email
  , 'B2B' as customer_category
  from
    specialty_shopify.customer
  )
/*
The "d2c_prospect" CTE checks to see if the email & D2C only exist in shopify and NOT netsuite. If so then this is considered a prospect.
aliases: 
  ds = d2c_shopify CTE
  n = ns CTE
*/  
, d2c_prospect as
  (
  select 
    ds.email
  , case when n.email is null then 1 else 0 end prospect_flag
  FROM
    d2c_shopify ds
  left join
    ns n
  on ds.email = n.email
  and n.customer_category = 'D2C'
  )
/*
The "b2b_prospect" CTE checks to see if the email & B2B only exist in shopify and NOT netsuite. If so then this is considered a prospect.
aliases: 
  bs = b2b_shopify CTE
  n = ns CTE
*/  
, b2b_prospect as
  (select 
    bs.email
  , case when n.email is null then 1 else 0 end prospect_flag
  FROM
    b2b_shopify bs
  left join
    ns n
  on bs.email = n.email
  and n.customer_category = 'B2B')
/*
  The "unions" CTE combines the netsuite, d2c_shopify, b2b_shopify CTEs and distincts to reduce to 1 record per email and category.
  aliases: 
    ds = d2c_shopify CTE
    bs = b2b_shop CTE
    n = ns CTE
*/  
 , unions as
  (
  SELECT distinct
    *
  from
    ns n
  union all 
    select * from d2c_shopify ds
  union all 
    select * from b2b_shopify bs
  ) 
/*
  The final step adds the prospect flag where needed and creates the md5 hash customer_id_edw for each email + category combination
  aliases: 
    dp = d2c_prospect CTE
    bp = b2b_prospect CTE
    u = unions CTE
*/ 
  select distinct
    u.email
  , u.customer_category
  , md5(concat(u.email, '::', u.customer_category)) customer_id_edw
  , coalesce(dp.prospect_flag,bp.prospect_flag,0) prospect_flag
  from
    unions u
  left join
    d2c_prospect dp
    on u.email = dp.email
    and u.customer_category = 'D2C'
  left join
    b2b_prospect bp
    on u.email = bp.email
    and u.customer_category = 'B2B'
  where
    u.email is not null
order by
  email