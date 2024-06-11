CREATE OR REPLACE TABLE fact.customer_ns_map COPY GRANTS AS
SELECT
  cust.customer_id_edw,
  ns_ids.value,
  nc.*
FROM
  dim.CUSTOMER cust
CROSS JOIN LATERAL FLATTEN(INPUT => cust.CUSTOMER_ID_NS) AS ns_ids
LEFT OUTER JOIN
      staging.netsuite_customers nc
      ON nc.customer_id_ns = ns_ids.value