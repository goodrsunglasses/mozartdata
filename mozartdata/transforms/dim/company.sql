--Note that this can and should morph into a '1 row per unique company' wherin we need to generate a unique company id, as it stands this is one row per shopify company id
--we then subsequently rejoin netsuite customer info back to it based on the custom field boomi leaves behind
-- CREATE OR REPLACE TABLE dim.company
--             COPY GRANTS  as
with
    distinct_companies as (
                              select distinct
                                  company_id
                                , name
                              from
                                  staging.shopify_companies
                          )
  , netsuite_companies_shopify as (
                              select
                                  customer_id_ns
                                , custentity_boomi_externalid as externalid
                                , shopify_parent_company_id
                                , shopify_sellgoodr_customer_id

                              from
                                  staging.netsuite_customers
                              where
                                  is_person_flag = 'F'--Hopefully this is true since company/customer records are only distinguished via a boolean
                          )
  , netsuite_companies_native as (
                              select
                                  customer_id_ns

                                , shopify_parent_company_id
                                , shopify_sellgoodr_customer_id
                              from
                                  staging.netsuite_customers
                              where
                                  is_parent_flag = true
                          )

select
    distinct_companies.company_id                     as company_id_shopify
  , distinct_companies.name                           as company_name_shopify
  , array_agg(distinct contact_customer_id)           as child_customer_ids_shopify
  , array_agg(distinct customer_id_ns)                as child_ids_ns_via_shop_parent--Ok important note here, I named this stupidly because this is a NS id FROM a join based on the shopify ID
  , array_agg(distinct shopify_sellgoodr_customer_id) as sellgoodr_ns_ids --to ascociate which original shopify profile they come from
  , array_agg(distinct externalid)
  , count(distinct zip)                               as distinct_zip_codes_shopify
from
    distinct_companies
    left outer join staging.shopify_companies company
        on company.company_id = distinct_companies.company_id
    left outer join netsuite_companies_shopify
        on netsuite_companies_shopify.shopify_parent_company_id = distinct_companies.company_id
where
    company_id_shopify = 3827499186
group by
    distinct_companies.company_id
  , distinct_companies.name
order by
    distinct_companies.name desc