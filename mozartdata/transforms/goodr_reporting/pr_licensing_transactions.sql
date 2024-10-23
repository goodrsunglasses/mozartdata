SELECT
  item.order_id_edw,
  item.product_id_edw,
  item.plain_name,
  concat(days.month_name,' ',days.year) as month_year
FROM
  fact.order_item item
  LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = item.order_id_edw
left outer join dim.date days on days.date =  ord.booked_date