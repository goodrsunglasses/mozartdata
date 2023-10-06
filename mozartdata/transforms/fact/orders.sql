WITH
  priority AS (
    SELECT
      order_id_edw,
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
  )
SELECT DISTINCT
  order_level.order_id_edw,
  order_level.channel,
  customer_id_edw,
  order_level.timestamp_transaction_pst,
  order_level.is_exchange,
  b2b_d2c,
  MAX(status_flag_edw) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS status_flag_edw,
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
  SUM(quantity_sold) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS quantity_sold,
  SUM(quantity_fulfilled) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS quantity_fulfilled,
  SUM(quantity_refunded) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS quantity_refunded,
  SUM(rate_items) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS rate_items,
   SUM(amount_items) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS amount_items,
  SUM(costestimate) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS costestimate,
  SUM(estgrossprofit) over (
    PARTITION BY
      order_level.order_id_edw
  ) AS estgrossprofit
FROM
  order_level
  LEFT OUTER JOIN fact.order_item orderitem ON orderitem.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN fact.orderline orderline ON orderline.order_id_edw = order_level.order_id_edw
  LEFT OUTER JOIN staging.dim_customer customer ON (
    customer.email = order_level.email
    AND customer.customer_category = order_level.b2b_d2c
  )
where order_level.order_id_edw = 'CI-F.MAY.101421'