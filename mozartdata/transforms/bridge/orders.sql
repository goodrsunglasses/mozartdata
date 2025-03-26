/*--first grab the netsuite info from dim.orders which implicitly should only
  have parent transactions from NS.
 */
WITH netsuite_info AS (SELECT orders.order_id_edw
							, orders.transaction_id_ns       AS parent_id
							, line.channel
							, category.currency_id_ns        AS channel_currency_id_ns
							, category.currency_abbreviation AS channel_currency_abbreviation
							, line.email
							, line.customer_id_ns
							, line.customer_id_edw
							, line.tier
							, line.location
							, line.warranty_order_id_ns
							, category.customer_category     AS b2b_d2c
							, category.model
					   FROM dim.orders AS orders
								LEFT OUTER JOIN
							fact.order_line AS line
							ON
								line.transaction_id_ns = orders.transaction_id_ns
								LEFT OUTER JOIN
							dim.channel AS category
							ON
								category.name = line.channel
					   WHERE
						   /* no need for checking if its a parent as the only transaction_id_ns's
							  that are in dim.orders are parents
							*/
						   orders.transaction_id_ns IS NOT NULL)
   , netsuite_aggregates AS (SELECT DISTINCT ns_parent.order_id_edw
										   , ns_parent.parent_id
										   , ns_parent.channel
										   , ns_parent.channel_currency_id_ns
										   , ns_parent.channel_currency_abbreviation
										   , ns_parent.email
										   , ns_parent.customer_id_ns
										   , ns_parent.customer_id_edw
										   , ns_parent.tier
										   , ns_parent.location
										   , ns_parent.warranty_order_id_ns
										   , ns_parent.b2b_d2c
										   , ns_parent.model
										   , MAX(status_flag_edw) OVER ( PARTITION BY orderline.order_id_edw )       AS status_flag_edw
										   , MAX(orderline.is_exchange) OVER ( PARTITION BY orderline.order_id_edw ) AS is_exchange
										   , FIRST_VALUE(transaction_date)
														 OVER (
															 PARTITION BY
																 orderline.order_id_edw
															 ORDER BY
																 CASE
																	 WHEN record_type = 'salesorder'
																		 THEN 1
																	 ELSE 2
																	 END
																 , transaction_created_timestamp_pst ASC
															 )                                                       AS booked_date
										   , FIRST_VALUE(CASE
															 WHEN orderline.record_type IN ('cashsale', 'invoice')
																 THEN orderline.transaction_date
															 ELSE NULL
															 END) OVER (
															 PARTITION BY
																 orderline.order_id_edw
															 ORDER BY
																 CASE
																	 WHEN orderline.record_type IN ('cashsale', 'invoice')
																		 THEN 1
																	 ELSE 2
																	 END
																 , orderline.transaction_created_timestamp_pst ASC
															 )                                                       AS sold_date
										   , FIRST_VALUE(CASE
															 WHEN record_type = 'itemfulfillment'
																 THEN transaction_date
															 ELSE NULL
															 END) OVER (
															 PARTITION BY
																 orderline.order_id_edw
															 ORDER BY
																 CASE
																	 WHEN record_type = 'itemfulfillment'
																		 THEN 1
																	 ELSE 2
																	 END
																 , transaction_created_timestamp_pst DESC
															 )                                                       AS fulfillment_date
										   , FIRST_VALUE(shipping_window_start_date)
														 IGNORE NULLS OVER (
															 PARTITION BY
																 orderline.order_id_edw
															 ORDER BY
																 shipping_window_start_date DESC
															 )                                                       AS shipping_window_start_date
										   , FIRST_VALUE(shipping_window_end_date)
														 IGNORE NULLS OVER (
															 PARTITION BY
																 orderline.order_id_edw
															 ORDER BY
																 shipping_window_end_date DESC
															 )                                                       AS shipping_window_end_date
							 FROM netsuite_info AS ns_parent
									  LEFT OUTER JOIN
								  fact.order_line AS orderline
								  ON
									  orderline.order_id_edw = ns_parent.order_id_edw)
   , shopify_info AS ( --Grab any and all shopify info from this CTE
	SELECT orders.order_id_edw
		 , shopify.amount_booked              AS amount_product_booked_shop
		 , shopify.shipping_sold              AS amount_shipping_booked_shop
		 , shopify.amount_tax_sold            AS amount_tax_booked_shop
		 , shopify.amount_standard_discount   AS amount_discount_booked_shop
		 , (shopify.amount_booked + shopify.shipping_sold -
			shopify.amount_standard_discount) AS amount_revenue_booked_shop
		 , (shopify.amount_booked + shopify.shipping_sold + shopify.amount_tax_sold -
			shopify.amount_total_discount)    AS amount_paid_booked_shop
		 , shopify.order_created_date_pst
		 , shopify.quantity_booked            AS quantity_booked_shopify
		 , shopify.quantity_sold              AS quantity_sold_shopify
	FROM dim.orders orders
			 LEFT OUTER JOIN
		 fact.shopify_orders shopify
		 ON
			 shopify.order_id_shopify = orders.order_id_shopify)
   , fulfillment_info AS (SELECT orders.order_id_edw
							   , SUM(quantity_ns)    AS total_quantity_ns
							   , SUM(quantity_stord) AS total_quantity_stord
							   , SUM(quantity_ss)    AS total_quantity_ss
						  FROM dim.orders AS orders
								   LEFT OUTER JOIN
							   dim.fulfillment AS fulfill
							   ON
								   fulfill.order_id_edw = orders.order_id_edw
								   LEFT OUTER JOIN
							   fact.fulfillment_item AS fulfill_item
							   ON
								   fulfill_item.fulfillment_id_edw = fulfill.fulfillment_id_edw
						  GROUP BY orders.order_id_edw)
   , aggregates AS (SELECT oi.order_id_edw
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.quantity_booked
				ELSE 0
				END
						   )                                AS quantity_booked
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.quantity_sold
				ELSE 0
				END
						   )                                AS quantity_sold
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.quantity_fulfilled
				ELSE 0
				END
						   )                                AS quantity_fulfilled
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.quantity_refunded
				ELSE 0
				END
						   )                                AS quantity_refunded
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.rate_booked
				ELSE 0
				END
						   )                                AS rate_booked
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.rate_sold
				ELSE 0
				END
						   )                                AS rate_sold
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.rate_refunded
				ELSE 0
				END
						   )                                AS rate_refunded
						 , SUM(oi.amount_revenue_booked)    AS amount_revenue_booked
						 , SUM(oi.amount_product_booked)    AS amount_product_booked
						 , SUM(oi.amount_discount_booked)   AS amount_discount_booked
						 , SUM(oi.amount_shipping_booked)   AS amount_shipping_booked
						 , SUM(oi.amount_tax_booked)        AS amount_tax_booked
						 , SUM(oi.amount_paid_booked)       AS amount_paid_booked
						 , SUM(oi.amount_revenue_sold)      AS amount_revenue_sold
						 , SUM(oi.amount_product_sold)      AS amount_product_sold
						 , SUM(oi.amount_discount_sold)     AS amount_discount_sold
						 , SUM(oi.amount_shipping_sold)     AS amount_shipping_sold
						 , SUM(oi.amount_tax_sold)          AS amount_tax_sold
						 , SUM(oi.amount_paid_sold)         AS amount_paid_sold
						 , SUM(oi.amount_cogs_fulfilled)    AS amount_cogs_fulfilled
						 , SUM(oi.amount_revenue_refunded)  AS amount_revenue_refunded
						 , SUM(oi.amount_product_refunded)  AS amount_product_refunded
						 , SUM(oi.amount_shipping_refunded) AS amount_shipping_refunded
						 , SUM(oi.amount_tax_refunded)      AS amount_tax_refunded
						 , SUM(oi.amount_paid_refunded)     AS amount_paid_refunded
						 , SUM(oi.revenue)                  AS revenue
						 , SUM(oi.amount_paid_total)        AS amount_paid_total
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.gross_profit_estimate
				ELSE 0
				END
						   )                                AS gross_profit_estimate
						 , SUM(
			CASE
				WHEN oi.plain_name NOT IN ('Tax', 'Shipping')
					THEN oi.cost_estimate
				ELSE 0
				END
						   )                                AS cost_estimate
					FROM fact.order_item oi
					GROUP BY order_id_edw)
, aftership_return_orders as (
        select distinct
            original_order_id_edw
        from
            fact.aftership_rmas
                    )
, aftership_exchange_orders as (
        select distinct
            exchange_order_id_edw
        from
            fact.aftership_rmas
                    )
SELECT orders.order_id_edw
	 , orders.order_id_ns
	 , aggregate_netsuite.channel
	 , aggregate_netsuite.customer_id_ns
	 , aggregate_netsuite.customer_id_edw
	 , aggregate_netsuite.tier
	 , location.name                                                               AS location
	 , aggregate_netsuite.warranty_order_id_ns
	 , COALESCE(
	--shopify shows first as it is considered the "booking" source of truth
		shopify_info.order_created_date_pst
	, aggregate_netsuite.booked_date
	   )                                                                           AS booked_date
	 , shopify_info.order_created_date_pst                                         AS booked_date_shopify
	 , aggregate_netsuite.booked_date                                              AS booked_date_ns
	 , aggregate_netsuite.sold_date
	 --placeholders for rn for when we ad a fulfillment source of truth
	 , aggregate_netsuite.fulfillment_date                                         AS fulfillment_date
	 , aggregate_netsuite.fulfillment_date                                         AS fulfillment_date_ns
	 , aggregate_netsuite.shipping_window_start_date
	 , aggregate_netsuite.shipping_window_end_date
	 , aggregate_netsuite.is_exchange
	 , aggregate_netsuite.status_flag_edw
	 , b2b_d2c
	 , aggregate_netsuite.model
	 , COALESCE(shopify_info.quantity_booked_shopify, aggregates.quantity_booked)  AS quantity_booked-- source of truth column for quantities also comes from shopify
	 , shopify_info.quantity_booked_shopify                                        AS quantity_booked_shopify
	 , aggregates.quantity_booked                                                  AS quantity_booked_ns
	 , shopify_info.quantity_sold_shopify                                          AS quantity_sold_shopify
	 , aggregates.quantity_sold                                                    AS quantity_sold_ns
	 , aggregates.quantity_sold
	 , CASE
		   WHEN aggregate_netsuite.channel NOT IN (
												   'Key Account', 'Key Accounts', 'Global', 'Prescription',
												   'Key Account CAN', 'Amazon Canada', 'Amazon Prime', 'Cabana',
												   'Amazon'
			   )
			   THEN (
			   COALESCE(
					   fulfillment_info.total_quantity_stord
				   , 0
			   ) + COALESCE(
					   fulfillment_info.total_quantity_ss
				   , 0
				   )
			   )
		   ELSE aggregates.quantity_fulfilled
	END                                                                            AS quantity_fulfilled--As per notes from our meeting, the idea is that on orders not in the channels, we dont want this column to show Netsuite IF information if its lacking from Stord/SS
	 , fulfillment_info.total_quantity_stord                                       AS quantity_fulfilled_stord
	 , fulfillment_info.total_quantity_ss                                          AS quantity_fulfilled_shipstation
	 , COALESCE(fulfillment_info.total_quantity_ns, aggregates.quantity_fulfilled) AS quantity_fulfilled_ns --This is a coalesce so that at least fact.orders will see that there is a quantity fulfilled, even if there is no tracking number
	 , aggregates.quantity_refunded
	 , aggregates.quantity_refunded                                                AS quantity_refunded_ns
	 , aggregates.rate_booked
	 , aggregates.rate_booked                                                      AS rate_booked_ns
	 , aggregates.rate_sold
	 , aggregates.rate_refunded
	 , aggregates.rate_refunded                                                    AS rate_refunded_ns
	 --shopify is also the source of truth for booking financial amount (SO's shouldnt matter GL wise anyways)
	 --converting shopify info from CAD to USD
	 --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_revenue_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_revenue_booked_shop
	END                                                                            AS amount_revenue_booked_shopify
	 , aggregates.amount_revenue_booked                                            AS amount_revenue_booked_ns
	 , COALESCE(amount_revenue_booked_shopify, amount_revenue_booked_ns)           AS amount_revenue_booked
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_revenue_booked_shop
	END                                                                            AS amount_revenue_booked_shopify_cad --this column shows the original CAD version of revenue, if applicable
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_product_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_product_booked_shop
	END                                                                            AS amount_product_booked_shopify
	 , aggregates.amount_product_booked                                            AS amount_product_booked_ns
	 , COALESCE(amount_product_booked_shopify, amount_product_booked_ns)           AS amount_product_booked
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_discount_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_discount_booked_shop
	END                                                                            AS amount_discount_booked_shopify
	 , aggregates.amount_discount_booked                                           AS amount_discount_booked_ns
	 , COALESCE(amount_discount_booked_shopify, amount_discount_booked_ns)         AS amount_discount_booked
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_tax_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_tax_booked_shop
	END                                                                            AS amount_tax_booked_shopify
	 , aggregates.amount_tax_booked                                                AS amount_tax_booked_ns
	 , COALESCE(shopify_info.amount_tax_booked_shop, aggregates.amount_tax_booked) AS amount_tax_booked
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_shipping_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_shipping_booked_shop
	END                                                                            AS amount_shipping_booked_shopify
	 , aggregates.amount_shipping_booked                                           AS amount_shipping_booked_ns
	 , COALESCE(amount_shipping_booked_shopify, amount_shipping_booked_ns)         AS amount_shipping_booked
	 , CASE
		   WHEN aggregate_netsuite.channel_currency_abbreviation = 'CAD'
			   THEN shopify_info.amount_paid_booked_shop * cer.exchange_rate
		   ELSE shopify_info.amount_paid_booked_shop
	END                                                                            AS amount_paid_booked_shopify
	 , aggregates.amount_paid_booked                                               AS amount_paid_booked_ns
	 , COALESCE(amount_paid_booked_shopify, amount_paid_booked_ns)                 AS amount_paid_booked
	 , aggregates.amount_revenue_sold
	 , aggregates.amount_product_sold
	 , aggregates.amount_discount_sold
	 , aggregates.amount_shipping_sold
	 , aggregates.amount_tax_sold
	 , aggregates.amount_paid_sold
	 , aggregates.amount_cogs_fulfilled
	 , aggregates.amount_revenue_refunded
	 , aggregates.amount_product_refunded
	 , aggregates.amount_shipping_refunded
	 , aggregates.amount_tax_refunded
	 , aggregates.amount_paid_refunded
	 , aggregates.revenue
	 , aggregates.amount_paid_total
	 , aggregates.gross_profit_estimate
	 , aggregates.cost_estimate
    , case
        when
            aftership_return_orders.original_order_id_edw is not null
        then
            true
        else
            false
    end as has_aftership_rma -- indicates if the order has an aftership rma associated with it
    , case
        when
            aftership_exchange_orders.exchange_order_id_edw is not null
        then
            true
        else
            false
    end as is_aftership_exchange -- indicates if the order was created by Aftership as part of an rma
-- case when aggregate_netsuite.tier like '%O' then true
--      when cust.first_order_id_edw_ns is not null and cust.customer_category = 'D2C' then TRUE
--      else false end as customer_first_order_flag
FROM dim.orders orders
		 LEFT OUTER JOIN netsuite_aggregates AS aggregate_netsuite
						 ON aggregate_netsuite.order_id_edw = orders.order_id_edw
		 LEFT OUTER JOIN shopify_info
						 ON shopify_info.order_id_edw = orders.order_id_edw
		 LEFT OUTER JOIN aggregates
						 ON aggregates.order_id_edw = aggregate_netsuite.order_id_edw
		 LEFT OUTER JOIN dim.location location
						 ON location.location_id_ns = aggregate_netsuite.location
		 LEFT OUTER JOIN fact.currency_exchange_rate cer
						 ON aggregate_netsuite.booked_date = cer.effective_date AND
							aggregate_netsuite.channel_currency_id_ns = cer.transaction_currency_id_ns
		 LEFT OUTER JOIN fulfillment_info
						 ON fulfillment_info.order_id_edw = orders.order_id_edw
         left join
            aftership_return_orders -- orders that have return or refund rmas
            on
                orders.order_id_edw = aftership_return_orders.original_order_id_edw
         left join
            aftership_exchange_orders -- orders that have exchange or warranty rmas
            on
                orders.order_id_edw = aftership_exchange_orders.exchange_order_id_edw
WHERE aggregate_netsuite.booked_date >= '2022-01-01T00:00:00Z'
ORDER BY aggregate_netsuite.booked_date DESC
