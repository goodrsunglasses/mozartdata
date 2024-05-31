CREATE OR REPLACE TABLE staging.shipstation_customers
            COPY GRANTS  as
SELECT customerid AS id,
	   name,
	   phone,
	   REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', '') AS normalized_phone_number,
	   email,
	   lower(email) as normalized_email,
	   city,
	   state,
	   countrycode,
	   postalcode,
	   STREET1,
	   street2,
	   createdate,
	   modifydate
FROM SHIPSTATION_PORTABLE.SHIPSTATION_CUSTOMERS_8589936627
