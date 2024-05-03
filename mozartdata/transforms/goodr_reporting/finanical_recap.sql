WITH
  cash AS (
    SELECT
      sum(net_amount) AS cash,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number >= 1010
      AND account_number < 1100
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
  revenue AS (
    SELECT
      sum(net_amount) AS revenue,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '4%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
  cogs AS (
    SELECT
      sum(net_amount) AS cogs,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '5%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
  opex AS (
    SELECT
      sum(net_amount) AS opex,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      (account_number LIKE '6%' or account_number LIKE '7%')
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
    fulfillment AS (
    SELECT
      sum(net_amount) AS fulfillment,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '60%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
  product_dev AS (
    SELECT
      sum(net_amount) AS product_dev,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '61%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
    sales_and_marketing AS (
    SELECT
      sum(net_amount) AS sales_and_marketing,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '63%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
    labor AS (
    SELECT
      sum(net_amount) AS labor,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      account_number LIKE '70%'
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  ),
    g_and_a AS (
    SELECT
      sum(net_amount) AS g_and_a,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      (account_number LIKE '7%' and account_number not like '70%') 
      AND posting_flag = 'true'
    GROUP BY
      posting_period
  )
SELECT
  cash.posting_period,
  cash.cash,
  revenue.revenue,
  cogs.cogs,
  opex.opex,
  revenue.revenue - cogs.cogs - opex.opex as net_income,
  fulfillment.fulfillment,
  product_dev.product_dev,
  sales_and_marketing.sales_and_marketing,
  labor.labor,
  g_and_a.g_and_a
FROM
  cash
  LEFT JOIN revenue ON cash.posting_period = revenue.posting_period
  LEFT JOIN cogs  ON cash.posting_period = cogs.posting_period 
  LEFT JOIN opex ON cash.posting_period = opex.posting_period 
  LEFT JOIN fulfillment ON cash.posting_period = fulfillment.posting_period 
  LEFT JOIN product_dev ON cash.posting_period = product_dev.posting_period
  LEFT JOIN sales_and_marketing ON cash.posting_period = sales_and_marketing.posting_period
  LEFT JOIN labor ON cash.posting_period = labor.posting_period
  LEFT JOIN g_and_a ON cash.posting_period = g_and_a.posting_period