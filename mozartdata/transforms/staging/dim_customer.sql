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
--, 'ns' as source
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
, d2c_shop as
(
  SELECT distinct
    lower(email) email
  , 'D2C' as customer_category
--  , 'goodr' as source
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