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
  default_payments AS (
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
  ),
  replicated_rows AS (
    SELECT
      payment_id,
      CASE
        WHEN row_num = 1 THEN 'Disb'
        WHEN row_num = 2 THEN 'Debit'
        WHEN row_num = 3 THEN 'Debit'
      END AS type,
      CASE
        WHEN row_num = 1 THEN concat('PAYMENT_AMOUNT ', payment_id)
        WHEN row_num = 2 THEN concat('PAYMENT_TOTAL ', payment_id)
        WHEN row_num = 3 THEN concat('RESERVE_FEE ', payment_id)
      END AS order_adjustment_id,
      statement_date,
      CASE
        WHEN row_num = 1 THEN PAYMENT_AMOUNT
        WHEN row_num = 2 THEN PAYMENT_TOTAL_FEES
        WHEN row_num = 3 THEN RESERVE_FEE
      END AS order_sales,
      NULL AS fees,
      NULL AS shipping,
      NULL AS CUSTOMER_PAID_SHIPPING_FEE_REFUND,
      NULL AS NET_SALES,
      NULL AS PAYMENT_AMOUNT,
      NULL AS PAYMENT_TOTAL_FEES,
      NULL AS SHIPPING_REFUND_TOTAL,
      NULL AS NET_SALES_TOTAL,
      NULL AS SHIPPING_TOTAL,
      NULL AS PAYMENT_TOTAL_SALES,
  null as RESERVE_FEE
    FROM
      (
        -- We use ROW_NUMBER to generate three rows per unique payment_id
        SELECT
          *,
          ROW_NUMBER() OVER (
            PARTITION BY
              payment_id
            ORDER BY
              order_adjustment_id
          ) AS row_num
        FROM
          default_payments
      ) AS numbered_rows
    WHERE
      row_num <= 3 -- Limit to 3 rows per payment_id
  )
SELECT
  payment_id,
  type,
  order_adjustment_id,
  statement_date,
  fees,
  shipping,
  customer_paid_shipping_fee_refund,
  net_sales,
  order_sales,
  payment_amount,
  payment_total_fees,
  shipping_refund_total,
  net_sales_total,
  shipping_total,
  payment_total_sales,
  reserve_fee
FROM
  replicated_rows
union all 
SELECT
  payment_id,
  type,
  to_varchar(order_adjustment_id) order_adjustment_id,
  statement_date,
  fees,
  shipping,
  customer_paid_shipping_fee_refund,
  net_sales,
  order_sales,
  payment_amount,
  payment_total_fees,
  shipping_refund_total,
  net_sales_total,
  shipping_total,
  payment_total_sales,
  reserve_fee
FROM
  default_payments
order by payment_id,net_sales