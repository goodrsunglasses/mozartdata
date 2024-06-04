--The idea of this approach is to break down the ascociation of emails and phone numbers to eventually form customer_id_edw's into a series of filtered steps,
-- isolating out the vast majority of customers who do not need special care, from the statistically small but annoying few that have whacky amounts of data splay attached to them.
WITH distinct_customers
		 AS -- Ok so the idea here is that you start by selecting a distinct list of all the combinations of phone numbers and emails from all our data sources that have customer data
	--CAVEAT HERE IS THAT WHENEVER WE ADD A NEW SYSTEM THEY NEED TO BE ADDED TO THESE FIRST COUPLE CTE'S UNLESS WE FEEL LIKE DOING DYNAMIC PARSING OF THE STAGING SCHEMA OR SUMN
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
	 isolated_customers
		 AS --Idea here is to find the customers that only exist in their respective systems for whatever reason, then grab those source Id's and their store, filtered for when there is no email and phone number
		 (SELECT DISTINCT id, source
		  FROM (SELECT id,
					   normalized_email,
					   normalized_phone_number,
					   store AS source
				FROM staging.SHOPIFY_CUSTOMERS
				UNION ALL
				SELECT id,
					   normalized_email,
					   normalized_phone_number,
					   'Netsuite' AS source
				FROM staging.netsuite_customers
				UNION ALL
				SELECT id,
					   normalized_email,
					   normalized_phone_number,
					   'Shipstation' AS source
				FROM staging.shipstation_customers)
		  WHERE NORMALIZED_PHONE_NUMBER IS NULL
			AND NORMALIZED_EMAIL IS NULL),
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
		 AS --Afterwords you then select a list of normalized emails and phone numbers to make a clean, non null list using the stringent where conditions found below
		 (SELECT DISTINCT *
		  FROM ranked_customers
		  WHERE (normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL)
			 OR (normalized_email IS NOT NULL AND has_both_email_and_phone = 0)
			 OR (normalized_phone_number IS NOT NULL AND has_both_phone_and_email = 0)),
	 exceptions_filter
		 AS --Then you go ahead and figure out all the problematic ones that would cause data splay, a relatively minor amount that we will deal with later, to get a list of the clean and simple customer ascociations
	 --note for later, this used to also consider when one phone number was shared by multiple emails, we removed this but its worth making note of as it can be used to detect resellers
		 (SELECT DISTINCT normalized_email AS problem_ids
		  FROM (SELECT DISTINCT COUNT(normalized_email) AS counter, normalized_email
				FROM clean_list
				GROUP BY normalized_email
				HAVING counter > 1)),
	 majority_pass
		 AS --The idea here is to get customer_id_edw's established for the 2,293,290 customers who don't need special attention to then later join to NS,Stord,shopify,etc...
		 (SELECT clean_list.normalized_email, clean_list.NORMALIZED_PHONE_NUMBER, filter.problem_ids
		  FROM clean_list
				   LEFT OUTER JOIN exceptions_filter filter
								   ON (filter.problem_ids = clean_list.NORMALIZED_PHONE_NUMBER OR
									   filter.problem_ids = clean_list.NORMALIZED_EMAIL)
		  WHERE problem_ids IS NULL),
	 prim_ident
		 AS --idea here is to establish the unique customers from the 2 CTE's we've established and filtered through to create a hashed ID we will use to join back to their source systems later on
		 (SELECT MD5(primary_identifier) as customer_id_edw,
		         primary_identifier,
		         method
		  FROM (SELECT NORMALIZED_EMAIL AS primary_identifier,
					   'Email'          AS method
				FROM majority_pass
				WHERE NORMALIZED_EMAIL IS NOT NULL
				UNION ALL
				SELECT NORMALIZED_PHONE_NUMBER AS primary_identifier,
					   'Phone'                 AS method
				FROM majority_pass
				WHERE NORMALIZED_EMAIL IS NULL
				UNION ALL
				SELECT to_char(id)          AS primary_identifier,
					   'Source_id' AS method
				FROM isolated_customers))
SELECT *
FROM prim_ident where method = 'Source_id'


/*
id = 1836849 is the generic D2C Customer. This is a catchall goodr.com customer only to be used when needing to mass import CSVs of SOs from Shopify

*/

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

