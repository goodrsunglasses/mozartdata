with ns as
  (
SELECT distinct
  t.email
, case 
  when channel.name in ('Key Account','Global','Specialty','Key Account CAN') then 'B2B' 
  else 'D2C' end customer_category
, 'ns' as source
FROM
  netsuite.transaction t
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
    email
  , 'D2C' as customer_category
  , 'goodr' as source
  from
    shopify.customer
  )
, b2b_shop as
(
  SELECT distinct
    email
  , 'B2B' as customer_category
  , 'goodr' as source
  from
    specialty_shopify.customer
  )
 , final as
  (SELECT distinct
    coalesce(a.email,b.email) email
    , coalesce(a.customer_category,b.customer_category) customer_category
    , coalesce(a.source,b.source) source
    , case when a.email is null then true else false end prospect_flag
  from
    ns a
  right join
   d2c_shop b
    on a.email = b.email
    and a.customer_category = b.customer_category
  ) select * from final where email = 'joe@sbrunningco.com'
  select email, channel.name from netsuite.transaction t
  LEFT OUTER JOIN 
  netsuite.customrecord_cseg7 channel
  on channel.id = t.cseg7
  where t.email in (select email from final where prospect_flag = true and customer_category = 'D2C')
  /*

select * from ns where email = 'sjones1@tarleton.edu'
--select * from netsuite.transaction t where email = 'katiewright0110@gmail.com'
*/