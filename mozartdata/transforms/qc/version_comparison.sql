WITH
  draft AS -- put the draft version or w/e of the table you wanna select in here if needed
  (
    WITH
      grid_days AS (
        SELECT
          ROW_NUMBER() over (
            ORDER BY
              SEQ4()
          ) -1 AS days
        FROM
          TABLE (GENERATOR(ROWCOUNT => 91)) a
        ORDER BY
          days
      ),
      grid_product AS (
        SELECT
          p.item_id_ns,
          d.days
        FROM
          dim.product p
          INNER JOIN goodr_reporting.launch_date_vs_earliest_sale ld ON p.item_id_ns = ld.item_id_ns
          AND earliest_d2c_sale >= '2023-01-01'
          INNER JOIN grid_days d ON 1 = 1
      ),
      launch_orders AS (
        SELECT
          oi.order_id_edw,
          ld.item_id_ns,
          o.sold_date,
          ld.display_name,
          ld.collection,
          ld.family,
          ld.earliest_d2c_sale,
          SUM(oi.amount_sold) launch_product_sales,
          SUM(oi.quantity_sold) launch_product_quantity
        FROM
          draft_fact.order_item oi
          INNER JOIN goodr_reporting.launch_date_vs_earliest_sale ld ON ld.item_id_ns = oi.item_id_ns
          AND ld.earliest_d2c_sale >= '2023-01-01'
          INNER JOIN draft_fact.orders o ON oi.order_id_edw = o.order_id_edw
          AND o.channel = 'Goodr.com'
        GROUP BY
          oi.order_id_edw,
          ld.item_id_ns,
          ld.display_name,
          ld.collection,
          ld.family,
          ld.earliest_d2c_sale,
          o.sold_date
      ),
      total_sales AS (
        SELECT
          lo.item_id_ns,
          (o.sold_date - lo.earliest_d2c_sale) AS days_since_launch,
          SUM(lo.launch_product_sales) AS launch_product_sales,
          SUM(lo.launch_product_quantity) AS launch_product_quantity,
          SUM(o.amount_sold) total_sales,
          SUM(o.quantity_sold) total_quantity,
          COUNT(DISTINCT o.order_id_edw) AS orders_containing_launch
        FROM
          draft_fact.orders o
          INNER JOIN launch_orders lo ON o.order_id_edw = lo.order_id_edw
        WHERE
          o.sold_date >= '2023-01-01'
        GROUP BY
          lo.item_id_ns,
          days_since_launch
      )
    SELECT
      gp.item_id_ns,
      gp.days,
      p.display_name,
      p.collection,
      p.family,
      p.sku,
      p.merchandise_class,
      p.merchandise_department,
      p.merchandise_division,
      ld.earliest_d2c_sale AS earliest_sale,
      COALESCE(ts.launch_product_sales, 0) launch_product_sales,
      COALESCE(ts.launch_product_quantity, 0) launch_product_quantity,
      COALESCE(ts.total_sales, 0) total_sales,
      COALESCE(ts.total_quantity, 0) total_quantity,
      COALESCE(ts.orders_containing_launch, 0) orders_containing_launch
    FROM
      grid_product gp
      INNER JOIN dim.product p ON gp.item_id_ns = p.item_id_ns
      INNER JOIN goodr_reporting.launch_date_vs_earliest_sale ld ON p.item_id_ns = ld.item_id_ns
      LEFT JOIN total_sales ts ON gp.item_id_ns = ts.item_id_ns
      AND gp.days = ts.days_since_launch
    WHERE
      p.merchandise_department = 'SUNGLASSES'
    ORDER BY
      gp.item_id_ns,
      days
      ---
  )
SELECT
  'Version 1 Only' AS source,
  v1.*
FROM
  goodr_reporting.launch_sales_by_sku v1
  LEFT JOIN draft ON (v1.item_id_ns = draft.item_id_ns and v1.days = draft.days)
WHERE
  draft.item_id_ns IS NULL
 union all 
  SELECT
  'Version 2 Only' AS source,
  draft.*
FROM
  draft
  LEFT JOIN goodr_reporting.launch_sales_by_sku v1 ON (v1.item_id_ns = draft.item_id_ns and v1.days = draft.days)
WHERE
  v1.item_id_ns IS NULL