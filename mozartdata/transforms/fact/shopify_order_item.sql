SELECT o.order_id_edw,
	   o.order_id_shopify,
	   o.store,
	   line.order_line_id_shopify,
	   line.product_id_shopify,
	   line.sku                                                                AS product_id_edw,
	   line.sku,
	   line.display_name,
	   line.price                                                              AS rate,
	   line.quantity                                                           AS quantity_booked,
	   line.quantity - line.fulfillable_quantity                               AS quantity_sold,
	   line.fulfillable_quantity                                               AS quantity_unfulfilled,
	   line.price * line.quantity                                              AS amount_booked,
	   line.price * (line.quantity - line.fulfillable_quantity)                AS amount_sold,
	   SUM(CASE
			   WHEN da.discount_code NOT LIKE 'YOTPO%' THEN da.amount
			   WHEN da.discount_code IS NULL AND da.TITLE IS NOT NULL THEN da.amount
			   ELSE 0 END)                                                     AS amount_discount_regular,
	   SUM(CASE WHEN da.discount_code LIKE 'YOTPO%' THEN da.amount ELSE 0 END) AS amount_yotpo,
	   SUM(da.amount)                                                          AS total_amount_discounted,
	   line.fulfillment_status
FROM staging.shopify_orders o
		 LEFT OUTER JOIN staging.shopify_order_line line
						 ON line.order_id_shopify = o.order_id_shopify AND line.store = o.store
		 LEFT OUTER JOIN fact.shopify_discount_item da
						 ON da.order_line_id_shopify = line.order_line_id_shopify AND da.store = o.store
		 LEFT OUTER JOIN dim.product p ON p.product_id_edw = line.sku
GROUP BY ALL
