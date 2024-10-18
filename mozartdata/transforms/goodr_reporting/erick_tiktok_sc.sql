WITH
  first AS (
    SELECT
      details.payment_id,
      order_adjustment_id,
      TO_CHAR(
        TO_DATE(details.statement_date_utc_, 'YYYY/MM/DD'),
        'MM/DD/YYYY'
      ) AS statement_date,
      fees,
      customer_paid_shipping_fee AS shipping,
      customer_paid_shipping_fee_refund,
      net_sales,
      net_sales + shipping + customer_paid_shipping_fee_refund AS order_sales,
      - payment_amount AS payment_amount
    FROM
      google_sheets.tiktok_sc_order_details details
      LEFT OUTER JOIN google_sheets.tiktok_sc_payments payments ON payments.payment_id = details.payment_id
    WHERE
      details.payment_id != '/'
    ORDER BY
      order_adjustment_id
  ),
  order_level AS (
    SELECT
      payment_id,
      order_adjustment_id,
      statement_date,
      payment_amount,
      sum(fees) AS order_fees,
      sum(order_sales) order_sales
    FROM
      first
    GROUP BY
      payment_id,
      payment_amount,
      order_adjustment_id,
      statement_date
  ),
  payment_level AS (
    SELECT
      payment_id,
      statement_date,
      payment_amount,
      sum(order_sales) sum_sales,
      sum(order_fees) sum_fees
    FROM
      order_level
    GROUP BY
      payment_id,
      statement_date,
      payment_amount
  )
SELECT
  payment_level.payment_id,
  'Cash Sale' as type,
  order_adjustment_id,
  payment_level.statement_date,
  payment_level.payment_amount,
  round(sum_fees,2) payment_fees,
  - round(sum_sales + sum_fees + payment_level.payment_amount, 2) AS reserve_fee
FROM
  payment_level
  left outer join order_level on order_level.payment_id = payment_level.payment_id
WHERE
  payment_level.payment_id = 3459278238115927000