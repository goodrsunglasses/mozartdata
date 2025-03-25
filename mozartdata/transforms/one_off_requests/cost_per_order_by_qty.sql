WITH
  qty AS (
    SELECT
      order_id_edw,
      quantity_sold,
      sold_date
    FROM
      fact.orders
  )
SELECT
  ship_month,
  case 
    when q.quantity_sold <= 5 then cast(q.quantity_sold as string)
    when q.quantity_sold > 5 then '6+'
    else null end as qty,
  sum(total_shipping_less_duties) AS total_shipping_less_duties,
  count(DISTINCT (order_id_edw_coalesce)) AS order_count_goodr,
  round(
    sum(total_shipping_less_duties) / count(DISTINCT (order_id_edw_coalesce)),
    3
  ) AS avg_order_cost
FROM
  s8.stord_invoices i 
  left join qty  q on upper(q.order_id_edw) = i.inv_order_id_edw
WHERE
  channel_coalesce = 'goodr.com'
GROUP BY
  ALL
ORDER BY
  ship_month