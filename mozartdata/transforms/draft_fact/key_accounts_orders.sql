WITH
  priority AS (
    SELECT distinct
      order_id_edw,
      MAX(status_flag_edw) over (
        PARTITION BY
          order_id_edw
      ) AS status_flag_edw,
      FIRST_VALUE(order_id_edw) OVER (
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
  where channel = 'Key Account'
  ),
  order_level AS (
    SELECT DISTINCT
      priority.order_id_edw,
      priority.id,
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
        orderline.order_id_edw = priority.id
        AND orderline.order_id_edw = priority.order_id_edw
      )
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      SUM(quantity_sold) quantity_sold,
      SUM(quantity_fulfilled) quantity_fulfilled,
      SUM(quantity_refunded) quantity_refunded,
      SUM(rate_sold) rate_sold,
      SUM(amount_sold) amount_sold,
      SUM(cost_estimate) cost_estimate,
      SUM(gross_profit_estimate) gross_profit_estimate
    FROM
      fact.order_item
    GROUP BY
      order_id_edw
  )
SELECT
  order_level.order_id_edw,
  order_level.channel,
  customer_id_edw,
  order_level.transaction_timestamp_pst,
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
  quantity_sold,
  quantity_fulfilled,
  quantity_refunded,
  rate_sold,
  amount_sold,
  cost_estimate,
  gross_profit_estimate
FROM
  order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw
  -- LEFT OUTER JOIN fact.order_line orderline ON orderline.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN dim.customer customer ON (
    lower(customer.email) = lower(order_level.email)
    AND customer.customer_category = order_level.b2b_d2c
  )
where transaction_timestamp_pst >= '2022-01-01T00:00:00Z'