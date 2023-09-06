WITH
  cust_tier AS (
    SELECT DISTINCT
      order_count,
      CASE
        WHEN order_count = 1 THEN 'NEW'
        WHEN order_count BETWEEN 2 and 5 THEN 'EXISTING'
        WHEN order_count >= 5 THEN 'FAN'
        ELSE 'N/A'
      END AS cust_tier
    FROM
      dim.customers
    ORDER BY
      order_count asc
  ),
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
      tran.estgrossprofit AS gross_profit,
      tran.estgrossprofitpercent AS profit_percent,
      tran.totalcostestimate,
      tran.entity AS customer_id
    FROM
      netsuite.transaction tran
    WHERE
      tran.recordtype IN ('cashsale', 'invoice', 'salesorder')
  )
SELECT
  DATE(prioritized_timestamp_tran) AS converted_timestamp,
  cust_tier,
  COUNT(orders.order_num) AS count_of_orders
FROM
  order_numbers orders
  JOIN dim.customers cust ON orders.customer_id = cust.cust_id_ns
  JOIN cust_tier ON cust.order_count = cust_tier.order_count
WHERE
  converted_timestamp >= DATEADD(DAY, -7, CURRENT_DATE())
  AND orders.prioritized_channel_id = 1
GROUP BY
  converted_timestamp,
  cust_tier
ORDER BY
  converted_timestamp asc