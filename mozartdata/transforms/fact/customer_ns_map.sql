SELECT
  prioritized_cust_id,
  b2b_d2c,
  entityid,
  customer_id_edw,
  CASE
    WHEN id IN (
      12489,
      479,
      465,
      476,
      8147,
      73200,
      3363588,
      8169,
      3633497,
      3682848,
      467,
      466,
      2510,
      478,
      475,
      4484902,
      4533439
    ) THEN TRUE
    ELSE FALSE
  END AS is_key_account_current
FROM
  draft_dim.draft_orders orders
  LEFT OUTER JOIN netsuite.customer ns_cust ON ns_cust.id = orders.prioritized_cust_id