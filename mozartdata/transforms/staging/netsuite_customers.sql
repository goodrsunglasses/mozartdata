CREATE OR REPLACE TABLE staging.netsuite_customers
	COPY GRANTS AS
SELECT cust.id                                                                 AS customer_id_ns,
	   cust.altname                                                            AS customer_name,
	   cust.entityid                                                           AS customer_number,
	   cust.parent                                                             AS parent_id_ns,
	   parent.ENTITYID                                                         AS parent_customer_number,
	   parent.altname                                                          AS parent_name,
	   cust.isperson                                                           AS is_person_flag,
	   CASE WHEN cust.parent IS NULL THEN TRUE ELSE FALSE END                  AS is_parent_flag,
	   cust.email,
	   NULLIF(LOWER(cust.email), '')                                        AS normalized_email,
	   cust.PHONE,
	   NULLIF(REGEXP_REPLACE(cust.phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   cust.firstname,
	   cust.lastname,
	   cust.firstorderdate,
	   cust.firstsaledate,
	   cust.LASTORDERDATE,
	   cust.lastsaledate,
	   cust.entitytitle,
	   cust.category,
	   cust.companyname as company_name,
	   cust.CUSTENTITY_BOOMI_EXTERNALID,
	   cust.CUSTENTITY_BOOMI_SOURCE,
	   cust.DATECREATED,
	   cust.DEFAULTBILLINGADDRESS,
	   cust.DEFAULTSHIPPINGADDRESS,
	   cust.custentityam_primary_sport as primary_sport,
     cust.custentityam_secondary_sport as secondary_sport,
     cust.custentityam_tertiary_sport as tertiary_sport,
     cust.custentityam_tier as tier,
     cust.custentityam_doors as doors,
     cust.custentityam_buyer_name as buyer_name,
     cust.custentityam_buyer_email as buyer_email,
     cust.custentityam_pop as pop,
     cust.custentityam_logistics as logistics,
     cust.custentityam_city_1 as city_1,
     cust.custentityam_city_2 as city_2,
     cust.custentityam_city_3 as city_3,
     cust.custentityam_state_1 as state_1,
     cust.custentityam_state_2 as state_2,
     cust.custentityam_state_3 as state_3,
	   cust.duplicate
FROM netsuite.customer cust
		 LEFT JOIN netsuite.customer parent
				   ON cust.parent = parent.id
WHERE cust._FIVETRAN_DELETED = FALSE
  AND (parent._FIVETRAN_DELETED = FALSE OR parent._FIVETRAN_DELETED IS NULL)

