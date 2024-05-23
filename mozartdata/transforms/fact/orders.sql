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
      shopify_line.amount_booked AS amount_product_booked_shop,
      shopify_line.shipping_sold AS amount_shipping_booked_shop,
      shopify_line.tax_sold AS amount_tax_booked_shop,
      shopify_line.amount_discount AS amount_discount_booked_shop,
      shopify_line.amount_booked+shopify_line.shipping_sold-shopify_line.amount_discount AS amount_revenue_booked_shop,
      shopify_line.amount_booked+shopify_line.shipping_sold+shopify_line.tax_sold-shopify_line.amount_discount AS amount_paid_booked_shop,
      order_created_date_pst,
      quantity_sold AS total_quantity_shopify
    FROM
      dim.orders orders
      LEFT OUTER JOIN fact.shopify_order_line shopify_line ON shopify_line.order_id_shopify = orders.order_id_shopify
  ),
  fulfillment_info AS ( --Grab any and all shopify info from this CTE
		 SELECT orders.order_id_edw,
				SUM(QUANTITY_NS)    AS total_QUANTITY_NS,
				SUM(QUANTITY_STORD) AS total_QUANTITY_STORD,
				SUM(QUANTITY_SS)    AS total_QUANTITY_SS
		 FROM dim.orders orders
				  LEFT OUTER JOIN dim.FULFILLMENT fulfill ON fulfill.ORDER_ID_EDW = orders.ORDER_ID_EDW
				  LEFT OUTER JOIN fact.fulfillment_item fulfill_item
								  ON fulfill_item.FULFILLMENT_ID_EDW = fulfill.FULFILLMENT_ID_EDW
		 GROUP BY orders.order_id_edw),
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
      oi.order_id_edw,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.quantity_booked ELSE 0 END) AS quantity_booked,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.quantity_sold ELSE 0 END) AS quantity_sold,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.quantity_fulfilled ELSE 0 END) AS quantity_fulfilled,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.quantity_refunded ELSE 0 END) AS quantity_refunded,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.rate_booked ELSE 0 END) AS rate_booked,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.rate_sold ELSE 0 END) AS rate_sold,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.rate_refunded ELSE 0 END) AS rate_refunded,
      SUM(oi.amount_revenue_booked) as amount_revenue_booked,
      SUM(oi.amount_product_booked) as amount_product_booked,
      SUM(oi.amount_discount_booked) as amount_discount_booked,
      SUM(oi.amount_shipping_booked) as amount_shipping_booked,
      SUM(oi.amount_tax_booked) as amount_tax_booked,
      SUM(oi.amount_paid_booked) as amount_paid_booked,
      SUM(oi.amount_revenue_sold) as amount_revenue_sold,
      SUM(oi.amount_product_sold) as amount_product_sold,
      SUM(oi.amount_discount_sold) as amount_discount_sold,
      SUM(oi.amount_shipping_sold) as amount_shipping_sold,
      SUM(oi.amount_tax_sold) as amount_tax_sold,
      SUM(oi.amount_paid_sold) as amount_paid_sold,
      SUM(oi.amount_cogs_fulfilled) as amount_cogs_fulfilled,
      SUM(oi.amount_revenue_refunded) as amount_revenue_refunded,
      SUM(oi.amount_product_refunded) as amount_product_refunded,
      SUM(oi.amount_shipping_refunded) as amount_shipping_refunded,
      SUM(oi.amount_tax_refunded) as amount_tax_refunded,
      SUM(oi.amount_paid_refunded) as amount_paid_refunded,
      SUM(oi.revenue) as revenue,
      SUM(oi.amount_paid_total) as amount_paid_total,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.gross_profit_estimate ELSE 0 END) AS gross_profit_estimate,
      SUM(CASE WHEN oi.plain_name NOT IN ('Tax', 'Shipping') THEN oi.cost_estimate ELSE 0 END) AS cost_estimate
    FROM
      fact.order_item oi
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
    aggregates.quantity_booked
  ) as quantity_booked,-- source of truth column for quantities also comes from shopify
  shopify_info.total_quantity_shopify as quantity_booked_shopify,
  aggregates.quantity_booked AS quantity_booked_ns,
  aggregates.quantity_sold,
  CASE WHEN channel NOT IN
				('Key Account', 'Global', 'Prescription', 'Key Account CAN', 'Amazon Canada', 'Amazon Prime', 'Cabana',
				 'Amazon')
       THEN (COALESCE(total_QUANTITY_STORD, 0) + COALESCE(total_QUANTITY_SS, 0))
		   ELSE quantity_fulfilled END              AS quantity_fulfilled,--As per notes from our meeting, the idea is that on orders not in the channels, we dont want this column to show Netsuite IF information if its lacking from Stord/SS
	   total_QUANTITY_STORD                         AS quantity_fulfilled_stord,
	   total_QUANTITY_SS                            AS  quantity_fulfilled_shipstation,
  aggregates.quantity_fulfilled,
  aggregates.quantity_fulfilled AS quantity_fulfilled_ns,
  aggregates.quantity_refunded,
  aggregates.quantity_refunded as quantity_refunded_ns,
  aggregates.rate_booked,
  aggregates.rate_booked as rate_booked_ns,
  aggregates.rate_sold,
  aggregates.rate_refunded,
  aggregates.rate_refunded as rate_refunded_ns,
  --shopify is also the source of truth for booking financial amount (SO's shouldnt matter GL wise anyways)
  --converting shopify info from CAD to USD
  --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_revenue_booked_shop*cer.exchange_rate else shopify_info.amount_revenue_booked_shop end as amount_revenue_booked_shopify,
  aggregates.amount_revenue_booked as amount_revenue_booked_ns,
  coalesce(amount_revenue_booked_shopify,amount_revenue_booked_ns) as amount_revenue_booked,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_revenue_booked_shop end as amount_revenue_booked_shopify_cad, --this column shows the original CAD version of revenue, if applicable
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_product_booked_shop*cer.exchange_rate else shopify_info.amount_product_booked_shop end as amount_product_booked_shopify,
  aggregates.amount_product_booked as amount_product_booked_ns,
  coalesce(amount_product_booked_shopify,amount_product_booked_ns) as amount_product_booked,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_discount_booked_shop*cer.exchange_rate else shopify_info.amount_discount_booked_shop end as amount_discount_booked_shopify,
  aggregates.amount_discount_booked as amount_discount_booked_ns,
  coalesce(amount_discount_booked_shopify, amount_discount_booked_ns) as amount_discount_booked,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_tax_booked_shop*cer.exchange_rate else shopify_info.amount_tax_booked_shop end as amount_tax_booked_shopify,
  aggregates.amount_tax_booked as amount_tax_booked_ns,
  coalesce(shopify_info.amount_tax_booked_shop, aggregates.amount_tax_booked) as amount_tax_booked,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_shipping_booked_shop*cer.exchange_rate else shopify_info.amount_shipping_booked_shop end as amount_shipping_booked_shopify,
  aggregates.amount_shipping_booked as amount_shipping_booked_ns,
  coalesce(amount_shipping_booked_shopify, amount_shipping_booked_ns) as amount_shipping_booked,
  case when aggregate_netsuite.channel_currency_abbreviation = 'CAD' then shopify_info.amount_paid_booked_shop*cer.exchange_rate else shopify_info.amount_paid_booked_shop end as amount_paid_booked_shopify,
  aggregates.amount_paid_booked as amount_paid_booked_ns,
  coalesce(amount_paid_booked_shopify,amount_paid_booked_ns) as amount_paid_booked,
  aggregates.amount_revenue_sold,
  aggregates.amount_product_sold,
  aggregates.amount_discount_sold,
  aggregates.amount_shipping_sold,
  aggregates.amount_tax_sold,
  aggregates.amount_paid_sold,
  aggregates.amount_cogs_fulfilled,
  aggregates.amount_revenue_refunded,
  aggregates.amount_product_refunded,
  aggregates.amount_shipping_refunded,
  aggregates.amount_tax_refunded,
  aggregates.amount_paid_refunded,
  aggregates.revenue,
  aggregates.amount_paid_total,
  aggregates.gross_profit_estimate,
  aggregates.cost_estimate
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
  LEFT OUTER JOIN fulfillment_info ON fulfillment_info.ORDER_ID_EDW = orders.ORDER_ID_EDW
WHERE
  aggregate_netsuite.booked_date >= '2022-01-01T00:00:00Z'
ORDER BY
  aggregate_netsuite.booked_date desc