SELECT
date(date_tran) as date,
sum(amount_items) as amount_daily,
sum(profit_gross) as profit_daily,
channel

FROM dim.orders

GROUP BY date, channel
  
ORDER BY 
date desc