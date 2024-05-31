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
								  FROM staging.shipstation_customers)),
	 ranked_customers AS (SELECT normalized_email,
								 normalized_phone_number,
								 CASE WHEN normalized_email IS NOT NULL THEN true ELSE false END as flagger,
								 CASE WHEN normalized_phone_number IS NOT NULL THEN true ELSE false END as flagger_2
						  FROM distinct_customers)
SELECT *
FROM ranked_customers
WHERE NORMALIZED_EMAIL = 'bevmaddylpn@yahoo.com'
  AND (flagger = true and flagger_2 = true)
SELECT COUNT(normalized_email) counter, normalized_email
FROM ranked_customers
where (flagger = true and flagger_2 = true)
GROUP BY normalized_email
HAVING counter > 2

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

