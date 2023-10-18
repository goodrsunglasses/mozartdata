WITH
  priority AS (
    SELECT DISTINCT
      order_id_edw,
      MAX(status_flag_edw) over (
        PARTITION BY
          order_id_edw
      ) AS status_flag_edw,
      FIRST_VALUE(ns_id) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN recordtype = 'cashsale' THEN 1
            WHEN recordtype = 'invoice' THEN 2
            WHEN recordtype = 'salesorder' THEN 3
            ELSE 4
          END,
          timestamp_transaction_pst ASC
      ) AS id
    FROM
      fact.order_line
  ),
  order_level AS (
    SELECT DISTINCT
      priority.order_id_edw,
      priority.id,
      channel,
      customer_id,
      email,
      is_exchange,
      priority.status_flag_edw,
      timestamp_transaction_pst,
      CASE
        WHEN channel IN (
          'Specialty',
          'Key Account',
          'Global',
          'Key Account CAN',
          'Specialty CAN'
        ) THEN 'B2B'
        WHEN channel IN (
          'Goodr.com',
          'Amazon',
          'Cabana',
          'Goodr.com CAN',
          'Prescription'
        ) THEN 'D2C'
        WHEN channel IN (
          'Goodrwill.com',
          'Customer Service CAN',
          'Marketing',
          'Customer Service'
        ) THEN 'INDIRECT'
      END AS b2b_d2c
    FROM
      priority
      LEFT OUTER JOIN fact.order_line orderline ON (
        orderline.ns_id = priority.id
        AND orderline.order_id_edw = priority.order_id_edw
      )
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_fulfilled
          ELSE 0
        END
      ) AS quantity_fulfilled,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_refunded
          ELSE 0
        END
      ) AS quantity_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_booked
          ELSE 0
        END
      ) AS rate_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_sold
          ELSE 0
        END
      ) AS rate_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_refunded
          ELSE 0
        END
      ) AS rate_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_booked
          ELSE 0
        END
      ) AS amount_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_sold
          ELSE 0
        END
      ) AS amount_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_refunded
          ELSE 0
        END
      ) AS amount_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN estgrossprofit
          ELSE 0
        END
      ) AS estgrossprofit,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN costestimate
          ELSE 0
        END
      ) AS costestimate,
  SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_booked
          ELSE 0
        END
      ) AS tax_booked,
  SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_sold
          ELSE 0
        END
      ) AS tax_sold,
  SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_refunded
          ELSE 0
        END
      ) AS tax_refunded,
  SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_booked
          ELSE 0
        END
      ) AS shipping_booked,
  SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_sold
          ELSE 0
        END
      ) AS shipping_sold,
  SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_refunded
          ELSE 0
        END
      ) AS shipping_refunded
    FROM
      fact.order_item
    GROUP BY
      order_id_edw
  )
SELECT
  order_level.order_id_edw,
  order_level.channel,
  customer_id_edw,
  order_level.timestamp_transaction_pst,
  order_level.is_exchange,
  order_level.status_flag_edw,
  b2b_d2c,
  CASE
    WHEN order_level.channel IN (
      'Specialty',
      'Key Account',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'Wholesale'
    WHEN order_level.channel IN ('Goodr.com', 'Goodr.com CAN') THEN 'Website'
    WHEN order_level.channel IN ('Amazon', 'Prescription') THEN 'Partners'
    WHEN order_level.channel IN ('Cabana') THEN 'Retail'
    WHEN order_level.channel IN ('Global') THEN 'Distribution'
  END AS model,
  quantity_booked,
  quantity_sold,
  quantity_fulfilled,
  quantity_refunded,
  rate_booked,
  rate_sold,
  rate_refunded,
  amount_booked,
  amount_sold,
  amount_refunded,
  aggregates.estgrossprofit,
  aggregates.costestimate,
  tax_booked,
  tax_sold,
  tax_refunded,
  shipping_booked,
  shipping_sold,
  shipping_refunded
FROM
  order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN staging.dim_customer customer ON (
    LOWER(customer.email) = LOWER(order_level.email)
    AND customer.customer_category = order_level.b2b_d2c
  )
WHERE
  timestamp_transaction_pst >= '2022-01-01T00:00:00Z'
ORDER BY
  timestamp_transaction_pst desc