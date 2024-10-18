WITH
  cust_info AS (
    SELECT
      customer_id_edw,
      customer_id_ns,
  customer_name,
      customer_number,
      parent_id_ns,
      parent_customer_number,
      parent_name,
      category,
      tier,
      doors
    FROM
      fact.customer_ns_map
    WHERE
      doors IS NOT NULL
      AND tier IS NOT NULL
  )
SELECT
  *
FROM
  cust_info
where parent_id_ns is not null