WITH
  conversion as
    (
      SELECT
        CURRENCY_EXCHANGE_RATE.effective_date
        , CURRENCY_EXCHANGE_RATE.exchange_rate
      FROM
        fact.currency_exchange_rate
      where CURRENCY_EXCHANGE_RATE.transaction_currency_abbreviation = 'CAD'
      QUALIFY row_number() over (order by CURRENCY_EXCHANGE_RATE.effective_date desc) = 1
    ),
  skus AS (
    SELECT
      oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store                                                                                           AS channel
    , CASE WHEN o.sold_date BETWEEN '2023-11-22' AND '2023-11-28' THEN 'BFCM-2023' ELSE 'BFCM-2024' END AS bfcm_period
    , COUNT(DISTINCT oi.order_id_edw)                                                                   AS order_count
    , SUM(oi.quantity_booked)                                                                           AS quantity_booked
    , case when o.store IN ('Specialty CAN', 'Goodr.ca') then SUM(oi.amount_product_booked) * avg(c.exchange_rate) else SUM(oi.amount_product_booked)              end                                                               AS amount_product
    , case when o.store IN ('Specialty CAN', 'Goodr.ca') then SUM(oi.amount_sales_booked)  * avg(c.exchange_rate) else SUM(oi.amount_sales_booked) end                                                                        AS amount_sales
    , case when o.store IN ('Specialty CAN', 'Goodr.ca') then SUM(oi.amount_yotpo_discount)     * avg(c.exchange_rate) else  SUM(oi.amount_yotpo_discount) end                                                                AS amount_yotpo_discount
    , case when o.store IN ('Specialty CAN', 'Goodr.ca') then SUM(oi.amount_refund_product)       * avg(c.exchange_rate) else avg(c.exchange_rate) end                                                              AS amount_refunded
    , case when o.store IN ('Specialty CAN', 'Goodr.ca') then SUM(oi.amount_gift_card_sold) * avg(c.exchange_rate) else SUM(oi.amount_gift_card_sold) end as amount_gift_card
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
      ON 1=1
    WHERE
       (o.sold_date BETWEEN '2023-11-22' AND '2023-11-28')
    OR (o.sold_date BETWEEN '2024-11-27' AND '2024-12-03')
        AND o.store NOT IN ('Goodrwill')
    GROUP BY
      oi.sku
    , oi.display_name
    , p.family
    , p.collection
    , o.sold_date
    , o.store
    , c.exchange_rate
    )
select * from skus