SELECT
  date(date_trunc(month, fulfillment_date)) as fulfillment_month,
  channel,
  sum(quantity_fulfilled) as qty_fulfilled 
FROM
  fact.orders
where channel <> 'global' 
  and fulfillment_month >= '2024-01-01'
group by all
order by 1, 2