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
  )
SELECT
  'Cash Sale' AS type,
  first.*,
  sum(fees) over (
    PARTITION BY
      payment_id
  ) payment_total_fees,
  sum(customer_paid_shipping_fee_refund) over (
    PARTITION BY
      payment_id
  ) shipping_refund_total,
  sum(net_sales) over (
    PARTITION BY
      payment_id
  ) net_sales_total,
  sum(shipping) over (
    PARTITION BY
      payment_id
  ) shipping_total,
  sum(order_sales) over (
    PARTITION BY
      payment_id
  ) payment_total_sales,
  - round(
    shipping_refund_total + shipping_total + net_sales_total + payment_total_fees + payment_amount,
    2
  ) AS reserve_fee
FROM
  first
ORDER BY
  payment_id