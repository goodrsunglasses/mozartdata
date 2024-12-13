/*
 BFCM 2024 - discount revenue
 */
WITH
  order_item AS
    (
      SELECT
        order_id_edw
      , sku
      , SUM(quantity_booked) AS quantity_booked
      , SUM(quantity_sold)   AS quantity_sold
      FROM
        fact.order_item oi
      GROUP BY ALL
      )
, prices     AS
    (
      SELECT
        sku
      , CASE
          WHEN p.merchandise_class IN
               ('ASTRO GS', 'BFGS', 'BOLT GS', 'BUG GS', 'FLEX GS', 'GLAM G', 'MACH GS', 'RUNWAYS', 'SUPER FLYS',
                'VRGS', 'WRAP GS') THEN 35
          WHEN p.merchandise_class IN ('CIRCLE GS', 'FLY GS', 'LFGS', 'MOON G', 'OGS', 'PHGS', 'POP GS', 'RETRO GS')
            THEN 25
          WHEN p.merchandise_class = 'SNOW G' THEN 75
          ELSE 0 END AS base_price_goodr
      , CASE
          WHEN p.merchandise_class IN
               ('ASTRO GS', 'BFGS', 'BOLT GS', 'BUG GS', 'FLEX GS', 'GLAM G', 'MACH GS', 'RUNWAYS', 'SUPER FLYS',
                'VRGS', 'WRAP GS') THEN 50
          WHEN p.merchandise_class IN ('CIRCLE GS', 'FLY GS', 'LFGS', 'MOON G', 'OGS', 'PHGS', 'POP GS', 'RETRO GS')
            THEN 40
          WHEN p.merchandise_class = 'SNOW G' THEN 100
          ELSE 0 END AS base_price_goodr_ca
      , CASE
          WHEN p.merchandise_class IN
               ('ASTRO GS', 'BFGS', 'BOLT GS', 'BUG GS', 'FLEX GS', 'GLAM G', 'MACH GS', 'RUNWAYS', 'SUPER FLYS',
                'VRGS', 'WRAP GS') THEN 17.5
          WHEN p.merchandise_class IN ('CIRCLE GS', 'FLY GS', 'LFGS', 'MOON G', 'OGS', 'PHGS', 'POP GS', 'RETRO GS')
            THEN 12.5
          WHEN p.merchandise_class = 'SNOW G' THEN 37.5
          ELSE 0 END AS base_price_sellgoodr
      , CASE
          WHEN p.merchandise_class IN
               ('ASTRO GS', 'BFGS', 'BOLT GS', 'BUG GS', 'FLEX GS', 'GLAM G', 'MACH GS', 'RUNWAYS', 'SUPER FLYS',
                'VRGS', 'WRAP GS') THEN 25
          WHEN p.merchandise_class IN ('CIRCLE GS', 'FLY GS', 'LFGS', 'MOON G', 'OGS', 'PHGS', 'POP GS', 'RETRO GS')
            THEN 20
          WHEN p.merchandise_class = 'SNOW G' THEN 50
          ELSE 0 END AS base_price_sellgoodr_ca
      FROM
        dim.product p
      )
, grid       AS (
  SELECT
    d.date as transaction_date
  , exchange_rate
  from
    dim.date d
  left join
    fact.currency_exchange_rate c
    on d.date = c.effective_date
    and c.transaction_currency_abbreviation = 'CAD'
  where
    date between '2024-11-26' and '2024-12-03'
    )

SELECT
  gt.transaction_id_ns
, gt.channel
, gt.order_id_edw
, gt.transaction_date
, gt.account_number
, gt.item_id_ns
, p.sku
, p.merchandise_class
, oi.quantity_sold
, oi.quantity_booked
, gt.net_amount as current_account_4000
, CASE
    WHEN gt.channel = 'Goodr.com' THEN base_price_goodr
    WHEN gt.channel = 'goodr.ca' THEN base_price_goodr_ca
    END                                                    AS base_price
, CASE
    WHEN gt.channel = 'Goodr.com' THEN base_price_goodr
    WHEN gt.channel = 'goodr.ca' THEN base_price_goodr_ca * g.exchange_rate
    END                                                    AS base_price_currency_converted
, case
  when gt.channel = 'Goodr.com' then (pr.base_price_goodr  * oi.quantity_sold) - gt.net_amount
  when gt.channel = 'goodr.ca' then (pr.base_price_goodr_ca  * oi.quantity_sold * g.exchange_rate) - gt.net_amount end AS amount_to_4110
, case
  when gt.channel = 'Goodr.com' then (pr.base_price_goodr  * oi.quantity_sold) - gt.net_amount
  when gt.channel = 'goodr.ca' then (pr.base_price_goodr_ca  * oi.quantity_sold * g.exchange_rate) - gt.net_amount end + gt.net_amount as new_account_4000 
FROM
  fact.gl_transaction gt
  LEFT JOIN
    dim.product p
    ON gt.item_id_ns = p.item_id_ns
  LEFT JOIN
    prices pr
    ON p.sku = pr.sku
  LEFT JOIN
    order_item oi
    ON gt.order_id_edw = oi.order_id_edw
      AND p.sku = oi.sku
  left join
    grid g
    on gt.transaction_date = g.transaction_date
WHERE
    gt.transaction_date BETWEEN '2024-11-26' AND '2024-12-03'
AND gt.posting_flag
AND gt.account_number LIKE '4000'
AND gt.channel IN ('Goodr.com','goodr.ca')
ORDER BY
  gt.transaction_id_ns
, gt.account_number
, p.sku