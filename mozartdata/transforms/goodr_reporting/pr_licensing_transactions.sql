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
      item.display_name,
      item.store,
      chan.customer_category,
      concat(days.month_name, ' ', days.year) AS month_year,
      sum(item.quantity_booked) AS total_quantity_booked,
      sum(item.quantity_sold) AS total_quantity_sold,
      sum(item.amount_booked) AS total_amount_booked,
      sum(item.amount_sold) AS total_amount_sold,
      sum(ref.quantity_refund_line) AS total_quantity_refunded,
      sum(ref.amount_refund_line_subtotal) AS total_amount_refunded
    FROM
      fact.shopify_order_item item
      LEFT OUTER JOIN fact.shopify_order_line line ON line.order_id_shopify = item.order_id_shopify
      LEFT OUTER JOIN dim.channel chan ON chan.name = item.store
      LEFT OUTER JOIN fact.shopify_refund_order_item ref ON ref.order_line_id = item.order_line_id_shopify
      LEFT OUTER JOIN dim.date days ON days.date = line.order_created_date
      LEFT OUTER JOIN dim.product prod ON prod.product_id_edw = item.product_id_edw
      LEFT OUTER JOIN google_sheets.licensing_sku_mapping licmap ON licmap.sku = prod.product_id_edw
    WHERE
      prod.family = 'LICENSING'
    GROUP BY
      ALL
  )
SELECT
  *
FROM
  ns_sourced
  -- SELECT
  --   ns_sourced.*,
  --   total_rate_sold + total_line_discount AS total_no_discounts
  -- FROM
  --   ns_sourced