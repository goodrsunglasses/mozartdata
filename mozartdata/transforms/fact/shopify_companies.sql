create or replace table fact.shopify_companies
    copy grants as
    --the idea of this table is to link the staging data to some peripherally useful shopify specific company level data
    with
        root_table as (
                          select
                              *
                          from
                              mozart.pipeline_root_table
        )
    select distinct --Adding distinct as a way to cut down on duplicated address fields I've noticed in test cases
                    company.id          as company_id
      ,             company.main_contact_id
      ,             company.created_at
      ,             company.external_id
      ,             company.name
      ,             company.note
      ,             company.updated_at
      ,             contact.customer_id as contact_customer_id
      ,             contact.is_main_contact
      ,             contact.updated_at  as contact_updated_at
      ,             addy.company        as company_address
      ,             addy.address_1
      ,             addy.address_2
      ,             addy.city
      ,             addy.country
      ,             addy.country_code
      ,             addy.province
      ,             addy.province_code
      ,             addy.zip
    from
        specialty_shopify.company                          company
        left outer join specialty_shopify.company_contact  contact
            on contact.company_id = company.id
        left outer join specialty_shopify.customer_address addy
            on addy.customer_id = contact.customer_id
    union all
    select distinct --Adding distinct as a way to cut down on duplicated address fields I've noticed in test cases
                    company.id          as company_id
      ,             company.main_contact_id
      ,             company.created_at
      ,             company.external_id
      ,             company.name
      ,             company.note
      ,             company.updated_at
      ,             contact.customer_id as contact_customer_id
      ,             contact.is_main_contact
      ,             contact.updated_at  as contact_updated_at
      ,             addy.company        as company_address
      ,             addy.address_1
      ,             addy.address_2
      ,             addy.city
      ,             addy.country
      ,             addy.country_code
      ,             addy.province
      ,             addy.province_code
      ,             addy.zip
    from
        sellgoodr_canada_shopify.company                          company
        left outer join sellgoodr_canada_shopify.company_contact  contact
            on contact.company_id = company.id
        left outer join sellgoodr_canada_shopify.customer_address addy
            on addy.customer_id = contact.customer_id