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
ranked_customers AS (
    SELECT
        normalized_email,
        normalized_phone_number,
        MAX(CASE WHEN normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL THEN 1 ELSE 0 END)
            OVER (PARTITION BY normalized_email) AS has_both_email_and_phone,
        MAX(CASE WHEN normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL THEN 1 ELSE 0 END)
            OVER (PARTITION BY normalized_phone_number) AS has_both_phone_and_email
    FROM distinct_customers
)
select * from ranked_customers where
    (normalized_email IS NOT NULL AND normalized_phone_number IS NOT NULL)
    OR (normalized_email IS NOT NULL AND has_both_email_and_phone = 0)
    OR (normalized_phone_number IS NOT NULL AND has_both_phone_and_email = 0)


-- select count(normalized_email) counter , normalized_email from ranked_customers group by  normalized_email having counter >2

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

