SELECT DISTINCT
  customer_id_edw,
  FIRST_VALUE(order_timestamp_pst) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      order_timestamp_pst asc
  ) first_order_date,
   FIRST_VALUE(order_id_edw) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      order_timestamp_pst asc
  ) first_order_id_ns,
  LAST_VALUE(order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      order_timestamp_pst asc
  ) most_recent_order_id_ns,
  LAST_VALUE(order_timestamp_pst) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      order_timestamp_pst asc
  ) most_recent_order_date,
  COUNT(DISTINCT order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
  ) AS order_count
FROM
  fact.orders