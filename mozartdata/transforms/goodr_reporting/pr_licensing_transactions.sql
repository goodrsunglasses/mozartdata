SELECT
  item.product_id_edw,
  item.plain_name,
  ord.channel,
  concat(days.month_name, ' ', days.year) AS month_year,
  sum(item.quantity_booked) total_quantity_booked,
  sum(item.rate_booked) total_rate_booked,
  sum(item.revenue) total_revenue,
  sum(item.gross_profit_estimate) total_gross_profit_estimate
  sum()
FROM
  fact.order_item item
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = item.order_id_edw
  LEFT OUTER JOIN dim.date days ON days.date = ord.booked_date
  LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = item.product_id_edw
  left outer join fact.netsuite_order_item_discounts discount on (discount.order_id_edw = item.order_id_edw and discount.product_id_edw = item.product_id_edw)
WHERE
  prod.family = 'LICENSING'
GROUP BY
  item.product_id_edw,
  item.plain_name,
  ord.channel,
  month_year