SELECT
  account_number,
  posting_period,
  channel,
  sku,
  display_name,
  sum(total_cogs) cogs,
  sum(quantity) as quantity,
  transaction_type
FROM s8.cogs_transactions
group by all