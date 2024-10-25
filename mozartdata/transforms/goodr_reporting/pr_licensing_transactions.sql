WITH
  ns_sourced AS (
    --bas
    SELECT
      item.product_id_edw,
      licmap.licensor,
      item.plain_name,
      ord.channel,
      ord.b2b_d2c,
      concat(days.month_name, ' ', days.year) AS month_year,
      sum(item.quantity_booked) total_quantity_booked,
      sum(item.rate_booked) total_rate_booked,
      sum(item.rate_sold) total_rate_sold,
      sum(item.revenue) total_revenue,
      sum(item.gross_profit_estimate) total_gross_profit_estimate,
      - round(sum(line_item_discount), 2) total_line_discount,
      sum(ref.quantity) AS total_quantity_refunded,
      sum(ref.rate) AS total_rate_refunded
    FROM
      fact.order_item item
      LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = item.order_id_edw
      LEFT OUTER JOIN dim.date days ON days.date = ord.booked_date
      LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = item.product_id_edw
      LEFT OUTER JOIN google_sheets.licensing_sku_mapping licmap ON licmap.sku = prod.product_id_edw
      LEFT OUTER JOIN fact.netsuite_order_item_discounts discount ON (
        discount.order_id_edw = item.order_id_edw
        AND discount.product_id_edw = item.product_id_edw
      )
      LEFT OUTER JOIN fact.netsuite_refund_item_detail ref ON (
        item.item_id_ns = ref.item_id_ns
        AND item.order_id_edw = ref.order_id_edw
      )
    WHERE
      prod.family = 'LICENSING'
      AND ord.booked_date >= '2022-01-01'
    GROUP BY
      item.product_id_edw,
      item.plain_name,
      b2b_d2c,
      ord.channel,
      licmap.licensor,
      month_year
  )
SELECT
  ns_sourced.*
FROM
  ns_sourced