SELECT customer_id_edw,
	   shopify_ids.value,
	   shop.*
FROM dim.CUSTOMER cust
		 CROSS JOIN LATERAL FLATTEN(INPUT => cust.CUSTOMER_ID_SHOPIFY) AS shopify_ids
		 LEFT OUTER JOIN staging.SHOPIFY_CUSTOMERS shop ON shop.DISTINCT_ID = shopify_ids.value