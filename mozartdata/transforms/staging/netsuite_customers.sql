CREATE OR REPLACE TABLE staging.netsuite_customers
	COPY GRANTS AS
SELECT id,
	   altname,
	   isperson,
	   email,
	   NULLIF(LOWER(email), '')                                        AS normalized_email,
	   PHONE,
	   NULLIF(REGEXP_REPLACE(phone, '\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   entityid,
	   firstname,
	   lastname,
	   firstorderdate,
	   firstsaledate,
	   LASTORDERDATE,
	   lastsaledate,
	   entitytitle,
	   category,
	   companyname,
	   CUSTENTITY_BOOMI_EXTERNALID,
	   CUSTENTITY_BOOMI_SOURCE,
	   DATECREATED,
	   DEFAULTBILLINGADDRESS,
	   DEFAULTSHIPPINGADDRESS,
	   duplicate
FROM netsuite.customer

