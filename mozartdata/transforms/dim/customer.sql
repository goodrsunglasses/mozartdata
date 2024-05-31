/*
id = 1836849 is the generic D2C Customer. This is a catchall goodr.com customer only to be used when needing to mass import CSVs of SOs from Shopify
*/

WITH distinct_customers AS (SELECT DISTINCT normalized_email,
											 normalized_phone_number
							FROM (SELECT normalized_email,
										 normalized_phone_number
								  FROM staging.SHOPIFY_CUSTOMERS
								  UNION ALL
								  SELECT normalized_email,
										 normalized_phone_number
								  FROM staging.netsuite_customers
								  UNION ALL
								  SELECT normalized_email,
										 normalized_phone_number
								  FROM staging.shipstation_customers))
SELECT *
FROM distinct_customers
WHERE normalized_email = 'ptigue88@gmail.com'
SELECT COUNT(email) counter, email
FROM distinct_customers
GROUP BY email
HAVING counter > 1

-- with ns as
--   (
-- SELECT distinct
--   lower(case when c.id= 1836849 then t.email else c.email end) email
-- , category.customer_category
-- FROM
--   netsuite.transaction t
-- inner join
--   netsuite.customer c
--   on t.entity = c.id
-- LEFT OUTER JOIN
--   netsuite.customrecord_cseg7 channel
--   on channel.id = t.cseg7
-- left outer join dim.channel category on category.name = channel.name
-- where
--   t.recordtype in ('salesorder','cashsale','invoice')
-- )

