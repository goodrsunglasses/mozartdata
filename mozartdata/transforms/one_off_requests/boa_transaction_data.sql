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
  conversion as
    (
      SELECT
        CURRENCY_EXCHANGE_RATE.effective_date
        , CURRENCY_EXCHANGE_RATE.exchange_rate
      FROM
        fact.currency_exchange_rate
      where CURRENCY_EXCHANGE_RATE.transaction_currency_abbreviation = 'CAD'
    ),
  skus AS (
    SELECT
      o.order_id_edw
    , o.customer_id_shopify
    , oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store                                                                                           AS channel
    , CASE WHEN o.sold_date BETWEEN '2023-11-22' AND '2023-11-28' THEN 'BFCM-2023' ELSE 'BFCM-2024' END AS bfcm_period
    , COUNT(DISTINCT oi.order_id_edw)                                                                   AS order_count
    , SUM(oi.quantity_booked)                                                                           AS quantity_booked
    , case when o.store ='Goodr.ca' then SUM(oi.amount_product_booked) * avg(c.exchange_rate) else SUM(oi.amount_product_booked)              end                                                               AS amount_product
    , case when o.store ='Goodr.ca' then SUM(oi.amount_sales_booked)  * avg(c.exchange_rate) else SUM(oi.amount_sales_booked) end                                                                        AS amount_sales
    , case when o.store = 'Goodr.ca' then SUM(oi.amount_yotpo_discount)     * avg(c.exchange_rate) else  SUM(oi.amount_yotpo_discount) end                                                                AS amount_yotpo_discount
    , case when o.store = 'Goodr.ca' then SUM(oi.amount_refund_product)       * avg(c.exchange_rate) else avg(c.exchange_rate) end                                                              AS amount_refunded
    , case when o.store = 'Goodr.ca' then SUM(oi.amount_gift_card_sold) * avg(c.exchange_rate) else SUM(oi.amount_gift_card_sold) end as amount_gift_card
    FROM
      fact.shopify_order_item oi
      INNER JOIN
        dim.product p
        ON oi.sku = p.product_id_edw
      LEFT JOIN
        fact.shopify_orders o
        ON oi.order_id_edw = o.order_id_edw
      LEFT JOIN
        conversion c
      ON o.sold_date = c.effective_date
    WHERE
      o.store IN ('Goodr.ca','Goodr.com')
    GROUP BY
      oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store
    , c.exchange_rate
    )
select * from skus order by