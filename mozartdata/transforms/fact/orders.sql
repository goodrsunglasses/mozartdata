WITH
  priority AS (
    SELECT distinct
      order_id_edw,
      MAX(status_flag_edw) over (
        PARTITION BY
          order_id_edw
      ) AS status_flag_edw,
      FIRST_VALUE(id) OVER (
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
      fact.orderline
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
      LEFT OUTER JOIN fact.orderline orderline ON (
        orderline.id = priority.id
        AND orderline.order_id_edw = priority.order_id_edw
      )
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      SUM(quantity_sold) quantity_sold,
      SUM(quantity_fulfilled) quantity_fulfilled,
      SUM(quantity_refunded) quantity_refunded,
      SUM(rate_items) rate_items,
      SUM(amount_items) amount_items,
      SUM(costestimate) costestimate,
      SUM(estgrossprofit) estgrossprofit
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
  quantity_sold,
  quantity_fulfilled,
  quantity_refunded,
  rate_items,
  amount_items,
  costestimate,
  estgrossprofit
FROM
  order_level
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = order_level.order_id_edw
  -- LEFT OUTER JOIN fact.orderline orderline ON orderline.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN staging.dim_customer customer ON (
    customer.email = order_level.email
    AND customer.customer_category = order_level.b2b_d2c
  )
where timestamp_transaction_pst >= '2022-01-01T00:00:00Z'