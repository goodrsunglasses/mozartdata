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
  p.sku = 'OG-BK-BL1'
  AND posting_period = 'Jun 2024'
  AND channel = 'Goodr.com'
GROUP BY
  ALL