WITH
  priority AS (
    SELECT DISTINCT
      order_id_edw,
      MAX(status_flag_edw) over (
        PARTITION BY
          order_id_edw
      ) AS status_flag_edw,
      MAX(has_refund) over (
        PARTITION BY
          order_id_edw
      ) AS has_refund,
      FIRST_VALUE(transaction_id_ns) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'cashsale' THEN 1
            WHEN record_type = 'invoice' THEN 2
            WHEN record_type = 'salesorder' THEN 3
            ELSE 4
          END,
          transaction_timestamp_pst ASC
      ) AS id
    FROM
      fact.order_line
  ),
  order_level AS (
    SELECT DISTINCT
      priority.order_id_edw,
      priority.id,
      priority.has_refund,
      channel,
      customer_id_ns,
      email,
      is_exchange,
      priority.status_flag_edw,
      transaction_timestamp_pst,
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
        orderline.transaction_id_ns = priority.id
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
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN gross_profit_estimate
          ELSE 0
        END
      ) AS gross_profit_estimate,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN cost_estimate
          ELSE 0
        END
      ) AS cost_estimate,
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
  order_level.transaction_timestamp_pst AS order_timestamp_pst,
  DATE(order_level.transaction_timestamp_pst) AS order_date_pst,
  order_level.is_exchange,
  order_level.status_flag_edw,
  order_level.has_refund,
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
  aggregates.gross_profit_estimate,
  aggregates.cost_estimate,
  tax_booked,
  tax_sold,
  tax_refunded,
  shipping_booked,
  shipping_sold,
  shipping_refunded
FROM
  order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN draft_dim.customer customer ON (
    LOWER(customer.email) = LOWER(order_level.email)
    AND customer.customer_category = order_level.b2b_d2c
  )
WHERE
  transaction_timestamp_pst >= '2022-01-01T00:00:00Z'
ORDER BY
  transaction_timestamp_pst desc