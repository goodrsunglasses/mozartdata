WITH
  fucked_up_amazon_ca AS (
    SELECT
      *
    FROM
      s8.cogs_transactions
    WHERE
      channel = 'Amazon Canada'
      AND record_type = 'cashsale'
      AND quantity > 0
      AND total_cogs <= 0
  ),
  fucked_up_amazon AS (
    SELECT
      *
    FROM
      s8.cogs_transactions
    WHERE
      channel = 'Amazon'
      AND record_type = 'cashsale'
      AND quantity > 0
      AND total_cogs <= 0
  )
SELECT
  c.account_number,
  c.posting_period,
  c.channel,
  p.family prod_cat,
  p.item_type,
  p.stage,
  c.sku,
  p.merchandise_class,
  p.merchandise_department,
  p.merchandise_division,
  p.design_tier,
  c.display_name,
  sum(c.total_cogs) cogs,
  sum(c.quantity) quantity,
  -- c.unit_cogs,
  c.transaction_type
FROM
  s8.cogs_transactions c
  LEFT JOIN dim.product p ON p.item_id_ns = c.item_id_ns
WHERE
  c.transaction_number_ns NOT IN (
        SELECT
          transaction_number_ns
        FROM
          fucked_up_amazon_ca
        UNION ALL
        SELECT
          transaction_number_ns
        FROM
          fucked_up_amazon
      )
  and ( p.merchandise_department = 'SUNGLASSES'
    OR p.sku IN ('G12107-YL', 'G12114', 'G12113', 'G12108-TL')  --- cases
      ) 

  AND c.transaction_type = 'SKU Cogs'
  and total_cogs >= 0   --- added per pr (remvoing from both revenue and cogs)
GROUP BY
  ALL