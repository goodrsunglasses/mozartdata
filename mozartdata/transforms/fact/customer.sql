SELECT DISTINCT
  customer_id_edw,
  FIRST_VALUE(sold_date) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      sold_date asc
  ) first_order_date,
   FIRST_VALUE(order_id_edw) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      sold_date asc
  ) first_order_id_ns,
  LAST_VALUE(order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
    ORDER BY
      sold_date asc
  ) most_recent_order_id_ns,
  LAST_VALUE(sold_date) OVER (
    PARTITION BY
     customer_id_edw
    ORDER BY
      sold_date asc
  ) most_recent_order_date,
  COUNT(DISTINCT order_id_edw) OVER (
    PARTITION BY
      customer_id_edw
  ) AS order_count
FROM
  fact.orders