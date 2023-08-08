/*
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
*/


SELECT
  date(date_tran) as date,
  channel,
  order_id,
  --sum(amount_items) as amount_daily,
  --sum(profit_gross) as profit_daily,
  --sum(quantity_items) as quantity_daily
  amount_items 

FROM dim.orders

WHERE date >= '2023-08-02' and channel = 'Customer Service' and amount_items <>0