/*
Purpose: show customers in Shipstation. One row per shipstation customer (customerid column).

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
SELECT customerid AS id,
	   name,
	   phone,
	   NULLIF(REGEXP_REPLACE(phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   email,
	   nullif(lower(email), '') as normalized_email,
	   city,
	   state,
	   countrycode,
	   postalcode,
	   STREET1,
	   street2,
	   createdate,
	   modifydate
FROM SHIPSTATION_PORTABLE.SHIPSTATION_CUSTOMERS_8589936627
