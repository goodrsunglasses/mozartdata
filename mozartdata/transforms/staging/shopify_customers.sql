/*
Purpose: The entire point of this table is to comfortably union all shopify stores'
customer information onto one table, as its split between 5 connectors.
One row per shopify customer per store

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
    SELECT id,
       'Goodr.com'                                                        AS store,
       'D2C'                                                              AS category,
       id || '_' || store                                                 AS distinct_id,--Needed because shopify reuses ID's between stores
       first_name,
       last_name,
       created_at,
       email,
       NULLIF(LOWER(email), '')                                           AS normalized_email,
       ORDERS_COUNT,
       phone,
       NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
       state                                                              as status,
       total_spent                                                        as lifetime_value,
       updated_at
FROM shopify.CUSTOMER
UNION ALL
SELECT id,
       'Specialty'                                                        AS store,
       'B2B'                                                              AS category,
       id || '_' || store                                                 AS distinct_id,
       first_name,
       last_name,
       created_at,
       email,
       NULLIF(LOWER(email), '')                                           AS normalized_email,
       ORDERS_COUNT,
       phone,
       NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
       state                                                              as status,
       total_spent                                                        as lifetime_value,
       updated_at
FROM SPECIALTY_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
       'Goodrwill'                                                        AS store,
       'INDIRECT'                                                         AS category,
       id || '_' || store                                                 AS distinct_id,
       first_name,
       last_name,
       created_at,
       email,
       NULLIF(LOWER(email), '')                                           AS normalized_email,
       ORDERS_COUNT,
       phone,
       NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
       state                                                              as status,
       total_spent                                                        as lifetime_value,
       updated_at
FROM GOODRWILL_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
       'Goodr.ca'                                                         AS store,
       'D2C'                                                              AS category,
       id || '_' || store                                                 AS distinct_id,
       first_name,
       last_name,
       created_at,
       email,
       NULLIF(LOWER(email), '')                                           AS normalized_email,
       ORDERS_COUNT,
       phone,
       NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
       state                                                              as status,
       total_spent                                                        as lifetime_value,
       updated_at
FROM GOODR_CANADA_SHOPIFY.CUSTOMER
UNION ALL
SELECT id,
       'Specialty CAN'                                                    AS store,
       'B2B'                                                              AS category,
       id || '_' || store                                                 AS distinct_id,
       first_name,
       last_name,
       created_at,
       email,
       NULLIF(LOWER(email), '')                                           AS normalized_email,
       ORDERS_COUNT,
       phone,
       NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
       state                                                              as status,
       total_spent                                                        as lifetime_value,
       updated_at
FROM SELLGOODR_CANADA_SHOPIFY.CUSTOMER