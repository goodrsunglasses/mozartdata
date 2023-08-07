SELECT
  date(date_tran) as date,
  channel,
  sum(amount_items) as amount_daily,
  sum(profit_gross) as profit_daily,
  sum(quantity_items) as quantity_daily

FROM dim.orders

WHERE date >= '2023-01-01'

GROUP BY date, channel
  
ORDER BY date desc