/*
id = 1836849 is the generic D2C Customer. This is a catchall goodr.com customer only to be used when needing to mass import CSVs of SOs from Shopify
*/

WITH distinct_customers
		 AS -- Ok so the idea here is that you start by selecting a distinct list of all the combinations of phone numbers and emails from all our data sources that have customer data
		 (SELECT DISTINCT normalized_email,
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
	 ranked_customers
		 AS --Then you go ahead and rank them to get rid of the cases when for example the same number shows up twice, but in one of the instances the email is null and vice versa
		 (SELECT normalized_email,
				 normalized_phone_number,
				 MAX(CASE
						 WHEN normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL
							 THEN 1
						 ELSE 0 END)
					 OVER (PARTITION BY normalized_email)        AS has_both_email_and_phone,
				 MAX(CASE
						 WHEN normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL
							 THEN 1
						 ELSE 0 END)
					 OVER (PARTITION BY normalized_phone_number) AS has_both_phone_and_email
		  FROM distinct_customers),
	 clean_list
		 AS --Afterworkds you then select a list of normalized emails and phone numbers to make a clean, non null list using the stringent where conditions found below
		 (SELECT DISTINCT *
		  FROM ranked_customers
		  WHERE (normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL)
			 OR (normalized_email IS NOT NULL AND has_both_email_and_phone = 0)
			 OR (normalized_phone_number IS NOT NULL AND has_both_phone_and_email = 0)),
	 exceptions_filter
		 AS --Then you go ahead and figure out all the problematic ones that would cause data splay, a relatively minor amount that we will deal with later, to get a list of the clean and simple customer ascociations
		 (SELECT DISTINCT normalized_phone_number AS problem_ids
		  FROM (SELECT DISTINCT COUNT(normalized_phone_number) AS counter,
								normalized_phone_number
				FROM clean_list
				GROUP BY normalized_phone_number
				HAVING counter > 1
				UNION ALL
				SELECT DISTINCT COUNT(normalized_email) AS counter,
								normalized_email
				FROM clean_list
				GROUP BY normalized_email
				HAVING counter > 1))
SELECT clean_list.normalized_email,
	   clean_list.NORMALIZED_PHONE_NUMBER,
	   filter.problem_ids
FROM clean_list
		 LEFT OUTER JOIN exceptions_filter filter ON (filter.problem_ids = clean_list.NORMALIZED_PHONE_NUMBER OR
													  filter.problem_ids = clean_list.NORMALIZED_EMAIL)
WHERE problem_ids IS NULL



--                                                                    where
--     (normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL)
--     OR (normalized_email IS NOT NULL AND has_both_email_and_phone = 0)
--     OR (normalized_phone_number IS NOT NULL AND has_both_phone_and_email = 0)
--                                                                    group by  normalized_phone_number having counter >2

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

