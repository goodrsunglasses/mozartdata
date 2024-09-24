--Assumptions made in this query that CAN be disproven, we assume that the discount amount from a parent transaction will be the EXACT same on all subsequent selling based ones
--Meaning that we're gonna grab the parent discount amount, then apply that on an aggregate amount to every item on all children transactions as well as itself.
--This WOULD break if say the aggregate amount of items on the selling portion is more than the booking portion, and this does happen but thats also a double charge in itself so not much to do there
WITH parent_discounts AS (SELECT --Ok so this is one row per NS transaction since each only have one discount ever
								 order_id_edw,
								 item_type,
								 plain_name,
								 rate,
								 rate_percent,
								 CASE WHEN rate_percent IS NOT NULL THEN TRUE ELSE FALSE END AS is_percent
						  FROM fact.order_item_detail
						  WHERE item_type = 'Discount'
							AND is_parent),
	 subtotal AS (SELECT --Apparently you need to calculate this manually so here we are lmao
						 order_id_edw,
						 SUM(rate) AS agg_subtotal
				  FROM fact.ORDER_ITEM_DETAIL
				  WHERE item_type NOT IN ('Discount', 'TaxItem', 'ShipItem')
					AND IS_PARENT
				  GROUP BY order_id_edw)
		,
	 application AS (SELECT--First do the math for percentage based ones, then the flat ones
						   parent_discounts.order_id_edw,
						   subtotal.agg_subtotal                             AS order_subtotal,
						   agg_subtotal * parent_discounts.rate_percent      AS flat_discount,
						   detail.item_id_ns,
						   detail.PRODUCT_ID_EDW,
						   detail.plain_name,
						   detail.rate                                          item_rate,
						   (item_rate / order_subtotal) * ABS(flat_discount) AS line_item_discount
					 FROM parent_discounts
							  LEFT OUTER JOIN subtotal ON subtotal.ORDER_ID_EDW = parent_discounts.ORDER_ID_EDW
							  LEFT OUTER JOIN fact.ORDER_ITEM_DETAIL detail
											  ON detail.ORDER_ID_EDW = parent_discounts.ORDER_ID_EDW
					 WHERE is_percent
					   AND IS_PARENT
					   AND detail.item_type NOT IN ('Discount', 'TaxItem', 'ShipItem')
					   AND agg_subtotal != 0
					 UNION ALL
					 SELECT parent_discounts.order_id_edw,
							subtotal.agg_subtotal                             AS order_subtotal,
							parent_discounts.rate                             AS flat_discount,
							detail.item_id_ns,
							detail.PRODUCT_ID_EDW,
							detail.plain_name,
							detail.rate                                          item_rate,
							(item_rate / order_subtotal) * ABS(flat_discount) AS line_item_discount
					 FROM parent_discounts
							  LEFT OUTER JOIN subtotal ON subtotal.ORDER_ID_EDW = parent_discounts.ORDER_ID_EDW
							  LEFT OUTER JOIN fact.ORDER_ITEM_DETAIL detail
											  ON detail.ORDER_ID_EDW = parent_discounts.ORDER_ID_EDW
					 WHERE is_percent = FALSE
					   AND IS_PARENT
					   AND detail.item_type NOT IN ('Discount', 'TaxItem', 'ShipItem')
					   AND agg_subtotal != 0)
SELECT *
FROM application
ORDER BY order_id_edw
