SELECT
  fc.*,
  nsc.customer_id_ns,
  nsc.customer_internal_id_ns
FROM
  fact.customer fc
  LEFT JOIN fact.customer_ns_map nsc ON nsc.customer_id_edw = fc.customer_id_edw
where b2b_d2c = 'B2B'