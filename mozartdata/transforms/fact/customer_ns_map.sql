SELECT
  cust.customer_id_edw
, nc.customer_id_ns
, nc.customer_name
, nc.customer_number
, nc.parent_id_ns
, nc.parent_customer_number
, nc.parent_name
, nc.is_person_flag
, nc.is_parent_flag
, nc.has_children_flag
, nc.email
, nc.normalized_email
, nc.phone
, nc.normalized_phone_number
, nc.first_name
, nc.last_name
, nc.first_order_date
, nc.first_sale_date
, nc.last_order_date
, nc.last_sale_date
, nc.entity_title
, nc.category_id_ns
, nc.category
, nc.company_name
, nc.custentity_boomi_externalid
, nc.custentity_boomi_source
, nc.created_date
, nc.default_billing_address
, nc.default_shipping_address
, nc.primary_sport_id_ns
, nc.primary_sport
, nc.secondary_sport_id_ns
, nc.secondary_sport
, nc.tertiary_sport_id_ns
, nc.tertiary_sport
, nc.tier_id_ns
, nc.tier_ns
, nc.tier
, nc.doors
, nc.buyer_name
, nc.buyer_email
, nc.pop_id_ns
, nc.pop
, nc.logistics_id_ns
, nc.logistics
, nc.city_1
, nc.city_2
, nc.city_3
, nc.state_1
, nc.state_2
, nc.state_3
, nc.duplicate
, ct.tier as tier_2024
,  case when cl.customer_id_ns is not null and cl.cluster is null then 3 else cl.cluster end as cluster
FROM
  dim.CUSTOMER cust
CROSS JOIN LATERAL FLATTEN(INPUT => cust.CUSTOMER_ID_NS) AS ns_ids
LEFT OUTER JOIN
      staging.netsuite_customers nc
      ON nc.customer_id_ns = ns_ids.value
LEFT OUTER JOIN
    staging.customer_tier_snapshot_2024 ct
    on nc.customer_id_ns = ct.customer_id_ns
LEFT OUTER JOIN
    csvs.netsuite_b2b_customer_clusters cl
    on nc.customer_id_ns = cl.customer_id_ns
