select
  c.posting_period
, c.period_end_date
, c.sku
, c.display_name
, c.channel
, c.transaction_type
, round(sum(c.total_cogs),2) total_cogs
, sum(c.quantity) total_quantity
, round(case
  when sum(c.quantity) = 0 then 0
  when c.transaction_type = 'SKU Cogs' then sum(c.total_cogs)/sum(c.quantity)
  else 0 end,2) as wac
from
  s8.cogs_transactions c
group by
  all
order by
  c.sku
, c.channel
, c.period_end_date asc