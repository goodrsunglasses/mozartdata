WITH
  order_posting AS ( --Basically because one order_id_edw doesn't have one posting period I need to find all the cashsale posting periods
    SELECT DISTINCT
      order_id_edw,
      posting_period
    FROM
      fact.gl_transaction
    WHERE
      posting_flag
      AND record_type IN ('cashsale', 'invoice')
  ),
  shop_refunds AS (
    SELECT
      days.posting_period,
      ref.sku AS product_id_edw,
      ref.store,
      sum(ref.quantity_refund_line) AS total_quantity_refunded,
      sum(ref.amount_refund_line_subtotal) AS total_amount_refunded
    FROM
      fact.shopify_refund_order_item_detail ref
      LEFT JOIN dim.date days ON ref.refund_created_date = days.date
    GROUP BY
      ALL
  ),
  ns_sourced AS ( --Just the data using NS as the only Source
    SELECT
      item.product_id_edw,
      licmap.licensor,
      item.plain_name,
      ord.channel,
      ord.b2b_d2c,
      posting_period,
      sum(item.quantity_booked) total_quantity_booked,
      sum(item.amount_revenue_sold) total_amount_revenue_sold,
      - round(sum(line_item_discount), 2) total_line_discount,
      sum(ref.quantity) AS total_quantity_refunded,
      sum(item.amount_revenue_refunded) total_amount_revenue_refunded
    FROM
      fact.order_item item
      LEFT OUTER JOIN fact.orders ord ON ord.order_id_edw = item.order_id_edw
      LEFT OUTER JOIN order_posting ON order_posting.order_id_edw = item.order_id_edw
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
    GROUP BY
      item.product_id_edw,
      item.plain_name,
      b2b_d2c,
      ord.channel,
      licmap.licensor,
      posting_period
  ),
  shopify_sourced AS (
    SELECT
      item.product_id_edw,
      licmap.licensor,
      prod.display_name,
      item.store,
      chan.customer_category,
      days.posting_period,
      sum(item.quantity_sold) AS total_quantity_booked,
      sum(item.amount_product_sold) AS total_amount_sold,
      sum(item.amount_standard_discount) AS total_standard_discount,
      ref.total_quantity_refunded AS total_quantity_refunded,
      ref.total_amount_refunded AS total_amount_refunded
    FROM
      fact.shopify_order_item item
      LEFT OUTER JOIN fact.shopify_orders ord ON ord.order_id_shopify = item.order_id_shopify
      LEFT OUTER JOIN dim.channel chan ON chan.name = item.store
      LEFT OUTER JOIN dim.date days ON days.date = ord.order_created_date
      LEFT OUTER JOIN shop_refunds ref ON ref.product_id_edw = item.product_id_edw
      AND ref.posting_period = days.posting_period
      AND ref.store = item.store
      LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = item.product_id_edw
      LEFT OUTER JOIN google_sheets.licensing_sku_mapping licmap ON licmap.sku = prod.product_id_edw
    WHERE
      prod.family = 'LICENSING'
    GROUP BY
      ALL
  ),
  sku_periods AS ( --Basically since we care about data only in one system, but want to include shopify/NS stuff on one line then we wanna go ahead and select the distinct month/year periods a given sku was sold
    SELECT DISTINCT
      *
    FROM
      (
        SELECT
          product_id_edw,
          posting_period,
          store AS channel,
          licensor
        FROM
          shopify_sourced
        UNION ALL
        SELECT
          product_id_edw,
          posting_period,
          channel,
          licensor
        FROM
          ns_sourced
      )
  ),
  calc_shopify AS (
    SELECT
      shopify_sourced.*,
      total_amount_sold - coalesce(total_amount_refunded, 0) + coalesce(total_standard_discount, 0) AS net_sales,
      total_amount_sold - coalesce(total_amount_refunded, 0) AS net_sales_no_discount
    FROM
      shopify_sourced
  ),
  calc_ns AS (
    SELECT
      ns_sourced.*,
      total_amount_revenue_sold - coalesce(total_amount_revenue_refunded, 0) + coalesce(total_line_discount, 0) AS net_sales,
      total_amount_revenue_sold - coalesce(total_amount_revenue_refunded, 0) AS net_sales_no_discount
    FROM
      ns_sourced
  )
SELECT
  prod.display_name,
  sku_periods.*,
  calc_ns.total_quantity_booked AS total_quantity_booked_ns,
  calc_shopify.total_quantity_booked AS total_quantity_booked_shop,
  calc_ns.total_amount_revenue_sold AS total_amount_revenue_sold_ns,
  calc_shopify.total_amount_sold AS total_amount_sold_shop,
  total_standard_discount AS total_discount_shop,
  total_line_discount AS total_discount_ns,
  calc_ns.total_quantity_refunded AS total_quantity_refunded_ns,
  calc_shopify.total_quantity_refunded AS total_quantity_refunded_shop,
  total_amount_revenue_refunded AS total_amount_revenue_refunded_ns,
  total_amount_refunded AS total_amount_refunded_shop,
  calc_ns.net_sales AS net_sales_ns,
  calc_shopify.net_sales AS net_sales_shop,
  calc_ns.net_sales_no_discount AS net_sales_no_discount_ns,
  calc_shopify.net_sales_no_discount AS net_sales_no_discount_shop
FROM
  sku_periods
  LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = sku_periods.product_id_edw
  LEFT OUTER JOIN calc_ns ON (
    calc_ns.product_id_edw = sku_periods.product_id_edw
    AND calc_ns.posting_period = sku_periods.posting_period
    AND calc_ns.channel = sku_periods.channel
  )
  LEFT OUTER JOIN calc_shopify ON (
    calc_shopify.product_id_edw = sku_periods.product_id_edw
    AND calc_shopify.posting_period = sku_periods.posting_period
    AND calc_shopify.store = sku_periods.channel
  )