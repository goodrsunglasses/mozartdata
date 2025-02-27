-- create or replace table fact.netsuite_companies
--     copy grants as
--the idea of this table is to move what was once a huge CTE on fact.company into a dedicated table for a solid view of netsuite customer information at the "company" level
select
    customer_id_ns
  , customer_name
  , parent_id_ns
  , is_parent_flag
  , has_children_flag
  , normalized_email
  , first_order_date
  , first_sale_date
  , last_order_date
  , last_sale_date
  , category
  , company_name
  , custentity_boomi_externalid
  , primary_sport
  , secondary_sport
  , tertiary_sport
  , tier
  , doors
  , shopify_parent_company_id
  , shopify_sellgoodr_customer_id

from
    staging.netsuite_customers cust
where
    is_person_flag = 'F'--Hopefully this is true since company/customer records are only distinguished via a boolean
    and is_parent_flag = false