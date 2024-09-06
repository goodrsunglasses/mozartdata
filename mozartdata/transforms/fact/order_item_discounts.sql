SELECT order_id_edw,
	   transaction_id_ns,
	   item_id_ns,
	   record_type,
	   item_type,
	   plain_name,
	   rate,
	   rate_percent,
	   CASE WHEN rate_percent IS NOT NULL THEN TRUE ELSE FALSE END AS is_percent
FROM fact.order_item_detail
WHERE order_id_edw IN ('G3346515', 'SG-91785')
  AND item_type = 'Discount'

