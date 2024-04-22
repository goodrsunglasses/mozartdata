WITH
  netsuite_info AS ( --first grab the netsuite info from dim.orders which implicitly should only have parent transactions from NS.
    SELECT
      orders.order_id_edw,
      orders.transaction_id_ns parent_id,
      line.channel,
      category.currency_id_ns as channel_currency_id_ns,
      category.currency_abbreviation as channel_currency_abbreviation,
      line.email,
      line.customer_id_ns,
      line.location,
      line.warranty_order_id_ns,
      customer_category AS b2b_d2c,
      model
    FROM
      dim.orders orders
      LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = orders.transaction_id_ns
      LEFT OUTER JOIN dim.channel category ON category.name = line.channel
    WHERE
      orders.transaction_id_ns IS NOT NULL -- no need for checking if its a parent as the only transaction_id_ns's that are in dim.orders are parents
  ),
  shopify_info AS ( --Grab any and all shopify info from this CTE
    SELECT
      orders.order_id_edw,
      shopify_line.amount_booked AS amount_booked_shopify,
      order_created_date_pst,
      quantity_sold AS total_quantity_shopify
    FROM
      dim.orders orders
      LEFT OUTER JOIN fact.shopify_order_line shopify_line ON shopify_line.order_id_shopify = orders.order_id_shopify
  ),
  aggregate_netsuite AS ( --aggregates the order level information from netsuite, this could definitely have been wrapped in the prior CTE but breaking it out made it more clear
    SELECT DISTINCT
      ns_parent.order_id_edw,
      ns_parent.parent_id,
      ns_parent.channel,
      ns_parent.channel_currency_id_ns,
      ns_parent.channel_currency_abbreviation,
      ns_parent.email,
      ns_parent.customer_id_ns,
      ns_parent.location,
      ns_parent.warranty_order_id_ns,
      ns_parent.b2b_d2c,
      ns_parent.model,
      MAX(status_flag_edw) over (
        PARTITION BY
          orderline.order_id_edw
      ) AS status_flag_edw,
      MAX(orderline.is_exchange) over (
        PARTITION BY
          orderline.order_id_edw
      ) AS is_exchange,
      FIRST_VALUE(transaction_date) OVER (
        PARTITION BY
          orderline.order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'salesorder' THEN 1
            ELSE 2
          END,
          transaction_created_timestamp_pst asc
      ) AS booked_date,
      FIRST_VALUE(
        CASE
          WHEN record_type IN ('cashsale', 'invoice') THEN transaction_date
          ELSE NULL
        END
      ) OVER (
        PARTITION BY
          orderline.order_id_edw
        ORDER BY
          CASE
            WHEN record_type IN ('cashsale', 'invoice') THEN 1
            ELSE 2
          END,
          transaction_created_timestamp_pst asc
      ) AS sold_date,
      FIRST_VALUE(
        CASE
          WHEN record_type = 'itemfulfillment' THEN transaction_date
          ELSE NULL
        END
      ) OVER (
        PARTITION BY
          orderline.order_id_edw
        ORDER BY
          CASE
            WHEN record_type = 'itemfulfillment' THEN 1
            ELSE 2
          END,
          transaction_created_timestamp_pst desc
      ) AS fulfillment_date,
      FIRST_VALUE(shipping_window_start_date) IGNORE NULLS OVER (
        PARTITION BY
          orderline.order_id_edw
        ORDER BY
          shipping_window_start_date desc
      ) AS shipping_window_start_date,
      FIRST_VALUE(shipping_window_end_date) IGNORE NULLS OVER (
        PARTITION BY
          orderline.order_id_edw
        ORDER BY
          shipping_window_end_date desc
      ) AS shipping_window_end_date
    FROM
      netsuite_info ns_parent
      LEFT OUTER JOIN fact.order_line orderline ON orderline.order_id_edw = ns_parent.order_id_edw
  ),
  aggregates AS (
    SELECT
      order_id_edw,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_booked
          ELSE 0
        END
      ) AS quantity_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_sold
          ELSE 0
        END
      ) AS quantity_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_fulfilled
          ELSE 0
        END
      ) AS quantity_fulfilled,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN quantity_refunded
          ELSE 0
        END
      ) AS quantity_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_booked
          ELSE 0
        END
      ) AS rate_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_sold
          ELSE 0
        END
      ) AS rate_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN rate_refunded
          ELSE 0
        END
      ) AS rate_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_booked
          ELSE 0
        END
      ) AS amount_booked,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_sold
          ELSE 0
        END
      ) AS amount_sold,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN amount_refunded
          ELSE 0
        END
      ) AS amount_refunded,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN gross_profit_estimate
          ELSE 0
        END
      ) AS gross_profit_estimate,
      SUM(
        CASE
          WHEN plain_name NOT IN ('Tax', 'Shipping') THEN cost_estimate
          ELSE 0
        END
      ) AS cost_estimate,
      SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_booked
          ELSE 0
        END
      ) AS tax_booked,
      SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_sold
          ELSE 0
        END
      ) AS tax_sold,
      SUM(
        CASE
          WHEN plain_name = 'Tax' THEN amount_refunded
          ELSE 0
        END
      ) AS tax_refunded,
      SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_booked
          ELSE 0
        END
      ) AS shipping_booked,
      SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_sold
          ELSE 0
        END
      ) AS shipping_sold,
      SUM(
        CASE
          WHEN plain_name = 'Shipping' THEN amount_refunded
          ELSE 0
        END
      ) AS shipping_refunded
    FROM
      fact.order_item
    GROUP BY
      order_id_edw
  ),
  refund_aggregates AS (
    SELECT DISTINCT
      order_id_edw,
      FIRST_VALUE(transaction_created_timestamp_pst) over (
        PARTITION BY
          order_id_edw
        ORDER BY
          transaction_created_timestamp_pst asc
      ) AS refund_timestamp_pst
    FROM
      fact.refund
  )
SELECT
  orders.order_id_edw,
  orders.order_id_ns,
  aggregate_netsuite.channel,
  customer_id_edw,
  location.name as location,
  aggregate_netsuite.warranty_order_id_ns,
  coalesce(
    shopify_info.order_created_date_pst,
    aggregate_netsuite.booked_date
  ) AS booked_date, --shopify shows first as it is considered the "booking" source of truth
  shopify_info.order_created_date_pst booked_date_shopify,
  aggregate_netsuite.booked_date booked_date_ns,
  aggregate_netsuite.sold_date,
  aggregate_netsuite.fulfillment_date AS fulfillment_date, --placeholder for rn for when we ad a fulfillment source of truth
  aggregate_netsuite.fulfillment_date AS fulfillment_date_ns,
  aggregate_netsuite.shipping_window_start_date,
  aggregate_netsuite.shipping_window_end_date,
  aggregate_netsuite.is_exchange,
  aggregate_netsuite.status_flag_edw,
  CASE
    WHEN refund.order_id_edw IS NOT NULL THEN TRUE
    ELSE FALSE
  END AS has_refund,
  refund_timestamp_pst,
  DATE(refund_timestamp_pst) AS refund_date_pst,
  b2b_d2c,
  aggregate_netsuite.model,
  coalesce(
    shopify_info.total_quantity_shopify,
    quantity_booked
  ) as quantity_booked,-- source of truth column for quantities also comes from shopify
  shopify_info.total_quantity_shopify as quantity_booked_shopify,
  quantity_booked AS quantity_booked_ns,
  quantity_sold,
  quantity_fulfilled,
  quantity_fulfilled AS quantity_fulfilled_ns,
  quantity_refunded,
  quantity_refunded as quantity_refunded_ns,
  rate_booked,
  rate_booked as rate_booked_ns,
  rate_sold,
  rate_refunded,
  rate_refunded as rate_refunded_ns,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then coalesce(amount_booked_shopify,amount_booked)*cer.exchange_rate else coalesce(amount_booked_shopify,amount_booked) end as amount_booked,--shopify is also the source of truth for booking financial amount (SO's shouldnt matter GL wise anyways)
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then amount_booked_shopify*cer.exchange_rate else amount_booked_shopify end as amount_booked_shopify, --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then amount_booked_shopify end as amount_booked_shopify_cad, --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
  amount_booked as amount_booked_ns,
  amount_sold,
  amount_refunded,
  amount_refunded as amount_refunded_ns,
  aggregates.gross_profit_estimate,
  aggregates.cost_estimate,
  tax_booked,--Keeping all of these with no suffix as to the best of my understanding we'll only ever see this in NS, however that can of course be changed
  tax_sold,
  tax_refunded,
  shipping_booked,
  shipping_sold,
  shipping_refunded
FROM
  dim.orders orders
  LEFT OUTER JOIN aggregate_netsuite ON aggregate_netsuite.order_id_edw = orders.order_id_edw
  LEFT OUTER JOIN shopify_info ON shopify_info.order_id_edw = orders.order_id_edw
  LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = aggregate_netsuite.order_id_edw
  LEFT OUTER JOIN dim.customer customer ON (
    LOWER(customer.email) = LOWER(aggregate_netsuite.email)
    AND customer.customer_category = aggregate_netsuite.b2b_d2c
  )
  LEFT OUTER JOIN refund_aggregates refund ON refund.order_id_edw = aggregate_netsuite.order_id_edw
  LEFT OUTER JOIN dim.location location ON location.location_id_ns = aggregate_netsuite.location
  LEFT OUTER JOIN fact.currency_exchange_rate cer ON aggregate_netsuite.booked_date = cer.effective_date AND aggregate_netsuite.channel_currency_id_ns = cer.transaction_currency_id_ns
WHERE
  aggregate_netsuite.booked_date >= '2022-01-01T00:00:00Z'
ORDER BY
  aggregate_netsuite.booked_date desc