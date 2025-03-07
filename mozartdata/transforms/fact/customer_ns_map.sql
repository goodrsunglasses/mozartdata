SELECT
  cust.customer_id_edw,
  nc.*,
  ct.tier as tier_2024
FROM
  dim.CUSTOMER cust
CROSS JOIN LATERAL FLATTEN(INPUT => cust.CUSTOMER_ID_NS) AS ns_ids
LEFT OUTER JOIN
      staging.netsuite_customers nc
      ON nc.customer_id_ns = ns_ids.value
LEFT OUTER JOIN
    staging.customer_tier_snapshot_2024 ct
    on nc.customer_id_ns = ct.customer_id_ns