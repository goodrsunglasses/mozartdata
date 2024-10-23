SELECT
  item.order_id_edw,
  item.product_id_edw,
  item.plain_name,
  concat(days.month_name, ' ', days.year) AS month_year,
FROM
  fact.order_item item
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = item.order_id_edw
  LEFT OUTER JOIN dim.date days ON days.date = ord.booked_date
  LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = item.product_id_edw
WHERE
  prod.family = 'Licensing'