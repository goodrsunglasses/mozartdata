SELECT
date(date_tran) as date,
sum(amount_items) as amount_daily,
channel
--profit_gross

FROM dim.orders

GROUP BY date, channel
  
ORDER BY 
date desc