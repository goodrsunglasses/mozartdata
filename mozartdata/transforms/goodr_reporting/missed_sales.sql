WITH
  inventory_levels AS
    (
      SELECT
        DATE_TRUNC(MONTH, snapshot_date) AS inventory_month
      , snapshot_date
      , store
      , il.sku
      , il.display_name
      , quantity AS starting_quantity
      , CASE WHEN quantity <= 0 THEN 1 ELSE 0 END AS oos_flag
      FROM
        fact.shopify_inventory il
        INNER JOIN
          dim.product p
          ON il.sku = p.sku
      WHERE
        p.family = 'INLINE'
      AND p.stage = 'ACTIVE'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          AND p.merchandise_department = 'SUNGLASSES'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      AND DATE_TRUNC(MONTH, snapshot_date) < DATE_TRUNC(MONTH, CURRENT_DATE)
      ORDER BY
        sku, snapshot_date ASC
      )
, total_quantity   AS
    (
      SELECT
        il.inventory_month
      , il.snapshot_date
      , il.sku
      , MAX(il.starting_quantity) AS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    max_quantity
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        , SUM(CASE WHEN il.store = 'Goodrwill' THEN il.starting_quantity ELSE 0 END) AS goodrwill_max_quantity
      FROM
        inventory_levels il
      GROUP BY
        il.inventory_month
      , il.snapshot_date
      , il.sku
      )
, daily_sales      AS
    (
      SELECT
        DATE_TRUNC(MONTH, ol.sold_date) AS sold_month
      , ol.sold_date
      , ol.store
      , oi.sku
      , oi.name                         AS display_name
      , SUM(oi.quantity_sold)           AS quantity_sold
      , SUM(oi.quantity_booked)         AS quantity_booked
      FROM
        fact.shopify_order_item oi
        INNER JOIN
          fact.shopify_order_line ol
          ON oi.order_id_shopify = ol.order_id_shopify
      GROUP BY
        DATE_TRUNC(MONTH, ol.sold_date)
      , ol.sold_date
      , ol.store
      , oi.sku
      , oi.name
      )
, avg_sales        AS
    (
      SELECT
        sold_month
      , store
      , sku
      , display_name
      , AVG(ds.quantity_sold) AS avg_sales
      FROM
        daily_sales ds
      GROUP BY
        sold_month
      , store
      , sku
      , display_name
      )
, final            AS
    (
      SELECT
        il.*
      , a.avg_sales
      , il.oos_flag * a.avg_sales AS quantity_missed_sales
      , tq.max_quantity
      , tq.goodrwill_max_quantity
      , CASE
          WHEN tq.max_quantity >= il.oos_flag * a.avg_sales AND il.oos_flag = 1 THEN 1
          ELSE 0 END              AS avoidable_missed_sale_flag
      , CASE
          WHEN tq.max_quantity >= il.oos_flag * a.avg_sales AND il.oos_flag = 1 THEN il.oos_flag * a.avg_sales
          ELSE 0 END              AS quantity_avoidable_missed_sale
      , CASE
          WHEN tq.goodrwill_max_quantity >= il.oos_flag * a.avg_sales AND il.oos_flag = 1 THEN 1
          ELSE 0 END              AS goodrwill_avoidable_missed_sale_flag
      , CASE
          WHEN tq.goodrwill_max_quantity >= il.oos_flag * a.avg_sales AND il.oos_flag = 1 THEN il.oos_flag * a.avg_sales
          ELSE 0 END              AS quantity_goodrwill_avoidable_missed_sale
      FROM
        inventory_levels il
        LEFT JOIN
          avg_sales a
          ON il.inventory_month = a.sold_month
            AND il.sku = a.sku
            AND il.store = CASE
                             WHEN a.store = 'Canada D2C' THEN 'Goodr.ca'
                             WHEN a.store = 'Specialty Canada' THEN 'Specialty CAN'
                             ELSE a.store END
        LEFT JOIN
          total_quantity tq
          ON il.snapshot_date = tq.snapshot_date
            AND il.sku = tq.sku
      ) --select * from inventory_levels where
SELECT
  inventory_month
, store
, sku
, display_name
, SUM(oos_flag)                                 AS days_oos
, COALESCE(SUM(quantity_missed_sales), 0)       AS missed_sales
, SUM(avoidable_missed_sale_flag)               AS days_avoidable_missed_sales
, SUM(goodrwill_avoidable_missed_sale_flag)     AS days_avoidable_missed_sales_goodrwill
, SUM(quantity_avoidable_missed_sale)           AS quantity_avoidable_missed_sale
, SUM(quantity_goodrwill_avoidable_missed_sale) AS quantity_goodrwill_avoidable_missed_sale
FROM
  final
WHERE
  store != 'Goodrwill'
GROUP BY
  inventory_month
, store
, sku
, display_name
HAVING
  days_oos > 0