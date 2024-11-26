/*
Requirements: (per team data slack thread)
For goodr.com and goodr.ca from Shopify 2018-2024:
Unique transaction ID
Unique customer ID
Order date
Product information (SKUs, Product Names, Price per Item, Discount, # of Items in Basket)
Regional information (aka ‘Ship To’ data) --> zip code is sufficient here
Any demographic information --> I don't believe we have anything here, correct?
Returns ($$ amount) --> we can only accurately tie returns to their original purchase in a small proportion of cases, correct?
Net sales
Gross sales
 
*/
WITH
  conversion AS
    (
      SELECT
        currency_exchange_rate.effective_date
      , currency_exchange_rate.exchange_rate
      FROM
        fact.currency_exchange_rate
      WHERE
        currency_exchange_rate.transaction_currency_abbreviation = 'CAD'
      )
, skus       AS (
      SELECT
        o.order_id_edw
      , o.customer_id_shopify
      , o.store                                                    AS channel
      , so.shipping_address_country_code as shipping_country
      , so.shipping_address_zip as shipping_zip_code
      , o.sold_date
      , oi.sku
      , oi.display_name
      , oi.quantity_booked                                         AS quantity_booked
      , oi.rate                                                    AS unit_price
      , sum(oi.amount_booked) as amount_booked
      , sum(oi.quantity_sold) as quantity_sold
      , sum(oi.amount_product_sold) as amount_sold
      , sum(oi.amount_standard_discount) as amount_discount
      , sum(oi.amount_refund_product) + sum(oi.amount_booked)-sum(oi.amount_product_sold) as amount_refund
--       , CASE
--           WHEN o.store = 'Goodr.ca' THEN SUM(oi.amount_booked) * AVG(c.exchange_rate)
--           ELSE SUM(oi.amount_booked) END                           AS amount_sold
--       , CASE
--           WHEN o.store = 'Goodr.ca' THEN SUM(oi.amount_standard_discount) * AVG(c.exchange_rate)
--           ELSE SUM(oi.amount_standard_discount) END                AS amound_discount
--       , CASE
--           WHEN o.store = 'Goodr.ca' THEN SUM(oi.amount_refund_product) * AVG(c.exchange_rate)
--           ELSE SUM(oi.amount_refund_product) END                   AS amount_refunded
      , sum(SUM(oi.quantity_booked)) OVER (PARTITION BY o.order_id_edw) AS order_quantity
      , sum(SUM(oi.amount_booked)) OVER (PARTITION BY o.order_id_edw) AS order_total
      , sum(SUM(oi.amount_standard_discount)) OVER (PARTITION BY o.order_id_edw) AS order_discount
      , o.shipping_sold as order_shipping
      , sum(sum(oi.amount_refund_product) + sum(oi.amount_booked)-sum(oi.amount_product_sold)) over (partition by o.order_id_edw) as order_refund
      FROM
        fact.shopify_order_item oi
        INNER JOIN
          dim.product p
          ON oi.sku = p.product_id_edw
        LEFT JOIN
          fact.shopify_orders o
          ON oi.order_id_edw = o.order_id_edw
          AND oi.store = o.store
        LEFT JOIN
          conversion c
          ON o.sold_date = c.effective_date
        LEFT JOIN
          staging.shopify_orders so
          ON o.order_id_shopify = so.order_id_shopify
          AND o.store = so.store
      WHERE
        o.store IN ('Goodr.ca', 'Goodr.com')
      GROUP BY ALL

      )
SELECT *
FROM
  skus
ORDER BY order_id_edw