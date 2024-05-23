WITH netsuite_info
		 AS ( --first grab the netsuite info from dim.orders which implicitly should only have parent transactions from NS.
		SELECT orders.order_id_edw,
			   orders.transaction_id_ns parent_id,
			   line.channel,
			   line.email,
			   line.customer_id_ns,
			   line.location,
			   line.warranty_order_id_ns,
			   customer_category AS     b2b_d2c,
			   model
		FROM dim.orders orders
				 LEFT OUTER JOIN fact.order_line line ON line.transaction_id_ns = orders.transaction_id_ns
				 LEFT OUTER JOIN dim.channel category ON category.name = line.channel
		WHERE orders.transaction_id_ns IS NOT NULL -- no need for checking if its a parent as the only transaction_id_ns's that are in dim.orders are parents
	),
	 shopify_info AS ( --Grab any and all shopify info from this CTE
		 SELECT orders.order_id_edw,
				shopify_line.amount_sold AS amount_sold_shopify,
				order_created_date_pst,
				quantity_sold            AS total_quantity_shopify
		 FROM dim.orders orders
				  LEFT OUTER JOIN fact.shopify_order_line shopify_line
								  ON shopify_line.order_id_shopify = orders.order_id_shopify),
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
	 aggregate_netsuite
		 AS ( --aggregates the order level information from netsuite, this could definitely have been wrapped in the prior CTE but breaking it out made it more clear
		 SELECT DISTINCT ns_parent.order_id_edw,
						 ns_parent.parent_id,
						 ns_parent.channel,
						 ns_parent.email,
						 ns_parent.customer_id_ns,
						 ns_parent.location,
						 ns_parent.warranty_order_id_ns,
						 ns_parent.b2b_d2c,
						 ns_parent.model,
						 MAX(status_flag_edw) OVER (
							 PARTITION BY
								 orderline.order_id_edw
							 )         AS status_flag_edw,
						 MAX(orderline.is_exchange) OVER (
							 PARTITION BY
								 orderline.order_id_edw
							 )         AS is_exchange,
						 FIRST_VALUE(transaction_date) OVER (
							 PARTITION BY
								 orderline.order_id_edw
							 ORDER BY
								 CASE
									 WHEN record_type = 'salesorder' THEN 1
									 ELSE 2
									 END, transaction_created_timestamp_pst ASC
							 )         AS booked_date,
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
											 END, transaction_created_timestamp_pst ASC
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
											 END, transaction_created_timestamp_pst DESC
									 ) AS fulfillment_date,
						 FIRST_VALUE(shipping_window_start_date) IGNORE NULLS OVER (
							 PARTITION BY
								 orderline.order_id_edw
							 ORDER BY
								 shipping_window_start_date DESC
							 )         AS shipping_window_start_date,
						 FIRST_VALUE(shipping_window_end_date) IGNORE NULLS OVER (
							 PARTITION BY
								 orderline.order_id_edw
							 ORDER BY
								 shipping_window_end_date DESC
							 )         AS shipping_window_end_date
		 FROM netsuite_info ns_parent
				  LEFT OUTER JOIN fact.order_line orderline
								  ON orderline.order_id_edw = ns_parent.order_id_edw),
	 aggregates AS (SELECT order_id_edw,
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
					FROM fact.order_item
					GROUP BY order_id_edw),
	 refund_aggregates AS (SELECT DISTINCT order_id_edw,
										   FIRST_VALUE(transaction_created_timestamp_pst) OVER (
											   PARTITION BY
												   order_id_edw
											   ORDER BY
												   transaction_created_timestamp_pst ASC
											   ) AS refund_timestamp_pst
						   FROM fact.refund)
SELECT orders.order_id_edw,
	   orders.order_id_ns,
	   aggregate_netsuite.channel,
	   customer_id_edw,
	   location.name                                AS location,
	   aggregate_netsuite.warranty_order_id_ns,
	   COALESCE(
			   shopify_info.order_created_date_pst,
			   aggregate_netsuite.booked_date
	   )                                            AS booked_date,           --shopify shows first as it is considered the "booking" source of truth
	   shopify_info.order_created_date_pst             booked_date_shopify,
	   aggregate_netsuite.booked_date                  booked_date_ns,
	   aggregate_netsuite.sold_date,
	   aggregate_netsuite.fulfillment_date          AS fulfillment_date,      --placeholder for rn for when we ad a fulfillment source of truth
	   aggregate_netsuite.fulfillment_date          AS fulfillment_date_ns,
	   aggregate_netsuite.shipping_window_start_date,
	   aggregate_netsuite.shipping_window_end_date,
	   aggregate_netsuite.is_exchange,
	   aggregate_netsuite.status_flag_edw,
	   CASE
		   WHEN refund.order_id_edw IS NOT NULL THEN TRUE
		   ELSE FALSE
		   END                                      AS has_refund,
	   refund_timestamp_pst,
	   DATE(refund_timestamp_pst)                   AS refund_date_pst,
	   b2b_d2c,
	   aggregate_netsuite.model,
	   COALESCE(
			   shopify_info.total_quantity_shopify,
			   quantity_booked
	   )                                            AS quantity_booked,-- source of truth column for quantities also comes from shopify
	   shopify_info.total_quantity_shopify          AS quantity_booked_shopify,
	   quantity_booked                              AS quantity_booked_ns,
	   quantity_sold,
	   CASE
		   WHEN channel NOT IN
				('Key Account', 'Global', 'Prescription', 'Key Account CAN', 'Amazon Canada', 'Amazon Prime', 'Cabana',
				 'Amazon')
			   THEN (COALESCE(total_QUANTITY_STORD, 0) + COALESCE(total_QUANTITY_SS, 0))
		   ELSE quantity_fulfilled END              AS quantity_fulfilled,--As per notes from our meeting, the idea is that on orders not in the channels, we dont want this column to show Netsuite IF information if its lacking from Stord/SS
	   total_QUANTITY_STORD                         AS quantity_fulfilled_stord,
	   total_QUANTITY_SS                               quantity_fulfilled_shipstation,
	   quantity_fulfilled                           AS quantity_fulfilled_ns,
	   quantity_refunded,
	   quantity_refunded                            AS quantity_refunded_ns,
	   rate_booked,
	   rate_booked                                  AS rate_booked_ns,
	   rate_sold,
	   rate_refunded,
	   rate_refunded                                AS rate_refunded_ns,
	   COALESCE(amount_sold_shopify, amount_booked) AS amount_booked,--shopify is also the source of truth for booking financial amount (SO's shouldnt matter GL wise anyways)
	   amount_sold_shopify                          AS amount_booked_shopify, --This sounds odd but it makes sense as shopify considers this "sold" but ns _sold is used to denote invoices and cash sales
	   amount_booked                                AS amount_booked_ns,
	   amount_sold,
	   amount_refunded,
	   amount_refunded                              AS amount_refunded_ns,
	   aggregates.gross_profit_estimate,
	   aggregates.cost_estimate,
	   tax_booked,--Keeping all of these with no suffix as to the best of my understanding we'll only ever see this in NS, however that can of course be changed
	   tax_sold,
	   tax_refunded,
	   shipping_booked,
	   shipping_sold,
	   shipping_refunded
FROM dim.orders orders
		 LEFT OUTER JOIN aggregate_netsuite ON aggregate_netsuite.order_id_edw = orders.order_id_edw
		 LEFT OUTER JOIN shopify_info ON shopify_info.order_id_edw = orders.order_id_edw
		 LEFT OUTER JOIN aggregates ON aggregates.order_id_edw = aggregate_netsuite.order_id_edw
		 LEFT OUTER JOIN dim.customer customer ON (
	LOWER(customer.email) = LOWER(aggregate_netsuite.email)
		AND customer.customer_category = aggregate_netsuite.b2b_d2c
	)
		 LEFT OUTER JOIN refund_aggregates refund ON refund.order_id_edw = aggregate_netsuite.order_id_edw
		 LEFT OUTER JOIN dim.location location ON location.location_id_ns = aggregate_netsuite.location
		 LEFT OUTER JOIN fulfillment_info ON fulfillment_info.ORDER_ID_EDW = orders.ORDER_ID_EDW
WHERE aggregate_netsuite.booked_date >= '2022-01-01T00:00:00Z'
ORDER BY aggregate_netsuite.booked_date DESC