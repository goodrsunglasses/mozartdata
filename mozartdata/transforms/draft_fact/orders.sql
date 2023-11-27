WITH
  parent_information AS (
    SELECT
      order_id_edw order_id,
      transaction_id_ns AS parent_id,
      orderline.channel,
      orderline.email,
      orderline.customer_id_ns,
      customer_category AS b2b_d2c,
      model
    FROM
      fact.order_line orderline
      LEFT OUTER JOIN dim.channel category ON category.name = orderline.channel
    WHERE
      parent_transaction = TRUE
  ),
  order_level AS (
    SELECT DISTINCT
      parent_information.order_id order_id_edw,
      parent_information.parent_id,
      parent_information.channel,
      parent_information.email,
      parent_information.customer_id_ns,
      parent_information.b2b_d2c,
      parent_information.model,
      MAX(status_flag_edw) over (
        PARTITION BY
          order_id_edw
      ) AS status_flag_edw,
      MAX(orderline.is_exchange) over (
        PARTITION BY
          order_id_edw
      ) AS is_exchange,
      FIRST_VALUE(transaction_timestamp_pst) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'salesorder'
            AND transaction_id_ns = parent_id THEN 1
            ELSE 2
          END,
          transaction_timestamp_pst asc
      ) AS booked_date,
      FIRST_VALUE(transaction_timestamp_pst) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type IN ('cashsale', 'invoice')
            AND createdfrom = parent_id THEN 1
            ELSE 2
          END,
          transaction_timestamp_pst asc
      ) AS sold_date,
      FIRST_VALUE(transaction_timestamp_pst) OVER (
        PARTITION BY
          order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'itemfulfillment'
            AND createdfrom = parent_id THEN 1
            ELSE 2
          END,
          transaction_timestamp_pst asc
      ) AS fulfillment_date
    FROM
      parent_information
      LEFT OUTER JOIN fact.order_line orderline ON orderline.order_id_edw = parent_information.order_id
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
  ),
  refund_aggregates AS (
    SELECT DISTINCT
      order_id_edw,
      FIRST_VALUE(transaction_timestamp_pst) over (
        PARTITION BY
          order_id_edw
        ORDER BY
          transaction_timestamp_pst asc
      ) AS refund_timestamp_pst
    FROM
      fact.refund
  )
SELECT
  order_level.order_id_edw,
  order_level.channel,
  customer_id_edw,
  order_level.booked_date,
  DATE(order_level.sold_date) AS booked_date_pst,
  order_level.sold_date,
  DATE(order_level.sold_date) AS sold_date_pst,
  order_level.fulfillment_date,
  DATE(order_level.sold_date) AS fulfillment_date_pst,
  order_level.is_exchange,
  order_level.status_flag_edw,
  CASE
    WHEN refund.order_id_edw IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS has_refund,
  refund_timestamp_pst,
  DATE(refund_timestamp_pst) AS refund_date_pst,
  b2b_d2c,
  order_level.model,
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
  LEFT OUTER JOIN dim.customer customer ON (
    LOWER(customer.email) = LOWER(order_level.email)
    AND customer.customer_category = order_level.b2b_d2c
  )
  LEFT OUTER JOIN refund_aggregates refund ON refund.order_id_edw = order_level.order_id_edw
WHERE
  order_level.booked_date >= '2022-01-01T00:00:00Z'
ORDER BY
  order_level.booked_date desc