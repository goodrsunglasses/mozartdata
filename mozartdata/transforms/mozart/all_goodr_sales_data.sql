WITH
  booked_shipping AS (
    -- Quick QC on this, no dupes; however, this is an ad hoc super fast patch.
    SELECT
      line.order_id_edw,
      addy.country,
      addy.state,
      addy.city,
      addy.zip,
      addy.addr1,
      addy.addr2,
      addy.addr3
    FROM
      fact.order_line line
      LEFT OUTER JOIN netsuite.salesordershippingaddress addy ON addy.nkey = line.shipping_address_ns
    WHERE
      line.record_type = 'salesorder'
  )
SELECT
  o.channel,
  EXTRACT(YEAR FROM o.sold_date) AS year,
  TO_CHAR(o.sold_date, 'YYYY-MM') AS sold_month,
  COALESCE(SUM(oi.revenue), 0) AS total_revenue,
  COALESCE(SUM(oi.quantity_sold), 0) AS total_quantity_sold
FROM
  fact.order_item oi
  LEFT JOIN fact.orders o ON o.order_id_edw = oi.order_id_edw
  LEFT JOIN dim.product p ON p.product_id_edw = oi.product_id_edw
  LEFT JOIN fact.customer_ns_map c ON o.customer_id_edw = c.customer_id_edw
  LEFT OUTER JOIN booked_shipping addy ON addy.order_id_edw = oi.order_id_edw
WHERE
  oi.product_id_edw IS NOT NULL
GROUP BY
  o.channel,
  EXTRACT(YEAR FROM o.sold_date),
  TO_CHAR(o.sold_date, 'YYYY-MM')
ORDER BY
  o.channel,
  year,
  sold_month;