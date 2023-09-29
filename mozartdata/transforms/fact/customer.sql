SELECT DISTINCT
  customer_id_edw,
  FIRST_VALUE(timestamp_transaction_pst) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      timestamp_transaction_pst asc
  ) first_order_date,
   FIRST_VALUE(order_id_edw) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      timestamp_transaction_pst asc
  ) first_order_id_ns,
  LAST_VALUE(order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      timestamp_transaction_pst asc
  ) most_recent_order_id_ns,
  LAST_VALUE(timestamp_transaction_pst) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      timestamp_transaction_pst asc
  ) most_recent_order_date,
  COUNT(DISTINCT order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
  ) AS order_count
FROM
  draft_dim.draft_orders
 
  -- CASE
  --   WHEN cust_id_ns IN (
  --     12489,
  --     479,
  --     465,
  --     476,
  --     8147,
  --     73200,
  --     3363588,
  --     8169,
  --     3633497,
  --     3682848,
  --     467,
  --     466,
  --     2510,
  --     478,
  --     475,
  --     4484902,
  --     4533439
  --   ) THEN TRUE
  --   ELSE FALSE
  -- END AS is_key_account_current