--Note that this can and should morph into a '1 row per unique company' wherin we need to generate a unique company id, as it stands this is one row per shopify company id
--we then subsequently rejoin netsuite customer info back to it based on the custom field boomi leaves behind
CREATE OR REPLACE TABLE dim.company
            COPY GRANTS  as
with
    distinct_companies as (
                              select distinct
                                  company_id
                                , name
                              from
                                  staging.shopify_companies
                          )
  , netsuite_companies as (--NOTE that technically this is not a catch all for all actual company records, but this exists to at least join to the existing ones from shopify
                              select
                                  customer_id_ns
                                , shopify_parent_id
                                , shopify_sellgoodr_id
                              from
                                  staging.netsuite_customers
                              where
                                  is_person_flag = 'F'--Hopefully this is true since company/customer records are only distinguished via a boolean
                          )

select
    distinct_companies.company_id as company_id_shopify
  , distinct_companies.name as company_name_shopify
  , array_agg(distinct contact_customer_id) as child_customer_ids_shopify
  , array_agg(distinct customer_id_ns)      as child_ids_ns_via_shop_parent--Ok important note here, I named this stupidly because this is a NS id FROM a join based on the shopify ID
  , count(distinct zip)                     as distinct_zip_codes_shopify
from
    distinct_companies
    left outer join staging.shopify_companies company
        on company.company_id = distinct_companies.company_id
    left outer join netsuite_companies
        on netsuite_companies.shopify_parent_id = distinct_companies.company_id
group by
    distinct_companies.company_id
  , distinct_companies.name
order by
    distinct_companies.name desc