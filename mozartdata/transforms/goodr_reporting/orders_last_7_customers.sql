SELECT
  DATE(prioritized_timestamp_tran) AS converted_timestamp,
  COUNT(order_num) AS order_count,
  cust_tier
FROM
  (
    WITH
      order_numbers AS (
        SELECT DISTINCT
          tran.custbody_goodr_shopify_order order_num,
          FIRST_VALUE(tran.cseg7) OVER (
            PARTITION BY
              order_num
            ORDER BY
              CASE
                WHEN tran.recordtype = 'cashsale' THEN 1
                WHEN tran.recordtype = 'invoice' THEN 2
                WHEN tran.recordtype = 'salesorder' THEN 3
                ELSE 4
              END
          ) AS prioritized_channel_id,
          FIRST_VALUE(tran.createddate) OVER (
            PARTITION BY
              order_num
            ORDER BY
              CASE
                WHEN tran.recordtype = 'cashsale' THEN 1
                WHEN tran.recordtype = 'invoice' THEN 2
                WHEN tran.recordtype = 'salesorder' THEN 3
                ELSE 4
              END
          ) AS prioritized_timestamp_tran,
          tran.entity AS customer_id
        FROM
          netsuite.transaction tran
        WHERE
          tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
      ),
      cust_order_count AS (
        SELECT DISTINCT
          cust_ns.id AS cust_id_ns,
          COUNT(DISTINCT tran_ns.custbody_goodr_shopify_order) OVER (
            PARTITION BY
              cust_ns.id
          ) AS order_count
        FROM
          netsuite.customer cust_ns
          LEFT OUTER JOIN netsuite.transaction tran_ns ON tran_ns.entity = cust_ns.id
      )
    SELECT
      orders.order_num,
      prioritized_timestamp_tran,
      cust_id_ns,
      cust_count.order_count,
      CASE
      WHEN cust_count.order_count = 1 THEN 'NEW'
      WHEN cust_count.order_count BETWEEN 2 and 5 THEN 'EXISTING'
      WHEN cust_count.order_count >= 5 THEN 'FAN'
      ELSE 'N/A'
      END AS cust_tier
    FROM
      order_numbers orders
      LEFT OUTER JOIN cust_order_count cust_count ON orders.customer_id = cust_count.cust_id_ns
    WHERE
      orders.prioritized_channel_id = 1
  )
WHERE
  converted_timestamp >= DATEADD(DAY, -7, CURRENT_DATE())
GROUP BY
  converted_timestamp,
  cust_tier