--The entire point of this table is to comfortably union all shopify product information onto one table, as its split between 5 connectors
CREATE OR REPLACE TABLE staging.shopify_customers
	COPY GRANTS AS
SELECT id,
	   'Goodr.com'                                                     AS store,
	   'D2C'                                                           AS category,
	   first_name,
	   last_name,
	   created_at,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   ORDERS_COUNT,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   state,
	   total_spent,
	   updated_at
FROM shopify.CUSTOMER
UNION ALL
SELECT id,
	   'Specialty'                                                     AS store,
	   'B2B'                                                           AS category,
	   first_name,
	   last_name,
	   created_at,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   ORDERS_COUNT,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   state,
	   total_spent,
	   updated_at
FROM SPECIALTY_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
	   'Goodrwill'                                                     AS store,
	   'INDIRECT'                                                      AS category,
	   first_name,
	   last_name,
	   created_at,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   ORDERS_COUNT,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   state,
	   total_spent,
	   updated_at
FROM GOODRWILL_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
	   'goodr.ca'                                                      AS store,--REPLICATED FROM HOW WE WROTE IT OUT IN NS IDK WHY NO CAPS
	   'D2C'                                                           AS category,
	   first_name,
	   last_name,
	   created_at,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   ORDERS_COUNT,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   state,
	   total_spent,
	   updated_at
FROM GOODR_CANADA_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
	   'Specialty CAN'                                                 AS store,
	   'B2B'                                                           AS category,
	   first_name,
	   last_name,
	   created_at,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   ORDERS_COUNT,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   state,
	   total_spent,
	   updated_at
FROM GOODRWILL_SHOPIFY.CUSTOMER