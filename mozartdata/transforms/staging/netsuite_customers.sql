with parents_list as
  (
    select distinct
      parent as customer_id_ns
    from
      netsuite.customer
  )
SELECT cust.id                                                                 AS customer_id_ns,
	   cust.altname                                                            AS customer_name,
	   cust.entityid                                                           AS customer_number,
	   cust.parent                                                             AS parent_id_ns,
	   parent.ENTITYID                                                         AS parent_customer_number,
	   parent.altname                                                          AS parent_name,
	   cust.isperson                                                           AS is_person_flag,
	   CASE WHEN cust.parent IS NULL THEN TRUE ELSE FALSE END                  AS is_parent_flag,
	   case when pl.customer_id_ns is not null then true else false end        AS has_children_flag,
	   cust.email,
	   NULLIF(LOWER(cust.email), '')                                        AS normalized_email,
	   cust.PHONE,
	   NULLIF(REGEXP_REPLACE(cust.phone, '^1|\\+1\\s?|\\(|\\)|-|\\s', ''), '') AS normalized_phone_number,
	   cust.firstname as first_name,
	   cust.lastname as last_name,
	   cust.firstorderdate as first_order_date,
	   cust.firstsaledate as first_sale_date,
	   cust.LASTORDERDATE as last_order_date,
	   cust.lastsaledate as last_sale_date,
	   cust.entitytitle as entity_title,
	   cust.category,
	   cust.companyname as company_name,
	   cust.CUSTENTITY_BOOMI_EXTERNALID,
	   cust.CUSTENTITY_BOOMI_SOURCE,
	   cust.DATECREATED as created_date,
	   cust.DEFAULTBILLINGADDRESS as default_billing_address,
	   cust.DEFAULTSHIPPINGADDRESS as default_shipping_address,
	   cust.custentityam_primary_sport as primary_sport_id_ns,
     pri.name as primary_sport,
     cust.custentityam_secondary_sport as secondary_sport_id_ns,
     sec.name as secondary_sport,
     cust.custentityam_tertiary_sport as tertiary_sport_id_ns,
     ter.name as tertiary_sport_id_ns,
     coalesce(parent_tier.id,tiers.id) as tier_id_ns,
     coalesce(parent_tier.name,tiers.name) as tier_ns,
     case when coalesce(parent_tier.name,tiers.name) = 'Named' then
       case when lower(cust.companyname) like '%fleet feet%' then 'Fleet Feet' else cust.companyname
       end else coalesce(parent_tier.name,tiers.name)  end as tier,
     cust.custentityam_doors as doors,
     cust.custentityam_buyer_name as buyer_name,
     cust.custentityam_buyer_email as buyer_email,
     cust.custentityam_pop as pop_id_ns,
     pop.name as pop,
     cust.custentityam_logistics as logistics_id_ns,
     log.name as logistics,
     cust.custentityam_city_1 as city_1,
     cust.custentityam_city_2 as city_2,
     cust.custentityam_city_3 as city_3,
     cust.custentityam_state_1 as state_1,
     cust.custentityam_state_2 as state_2,
     cust.custentityam_state_3 as state_3,
	   cust.duplicate
FROM netsuite.customer cust
    LEFT JOIN parents_list pl
      on cust.id = pl.customer_id_ns
		LEFT JOIN netsuite.customer parent
				   ON cust.parent = parent.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_TIERS tiers
          ON cust.custentityam_tier = tiers.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_TIERS parent_tier
          ON parent.custentityam_tier = parent_tier.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_TIERS pop
          ON cust.custentityam_pop = pop.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_LOGISTICS log
          ON cust.custentityam_logistics = log.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_SUBCATS pri
          ON cust.custentityam_primary_sport = pri.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_SUBCATS sec
          ON cust.custentityam_secondary_sport = sec.id
    LEFT JOIN netsuite.CUSTOMLISTB2B_MATRIX_SUBCATS ter
          ON cust.custentityam_tertiary_sport = ter.id
WHERE cust._FIVETRAN_DELETED = FALSE
  AND (parent._FIVETRAN_DELETED = FALSE OR parent._FIVETRAN_DELETED IS NULL)
