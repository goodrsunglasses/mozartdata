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
							AND is_parent
							AND ORDER_ID_EDW IN ('G3346515', 'SG-91785')
						  ORDER BY ORDER_ID_EDW),
	 subtotal AS (SELECT --Apparently you need to calculate this manually so here we are lmao
	                  order_id_edw,
						 SUM(rate) AS agg_subtotal
				  FROM fact.ORDER_ITEM_DETAIL
				  WHERE item_type NOT IN ('Discount', 'TaxItem', 'ShipItem')
					AND IS_PARENT
				  GROUP BY order_id_edw)
--      ,
-- 	 application AS (SELECT--First do the math for percentage based ones, then the flat ones
-- 	                     parent_discounts.order_id_edw,
-- 	                      parent_discounts.rate_percent
-- 					 FROM parent_discounts
-- 					 WHERE is_percent and item_type !='Discount'--According to Alex, discounts apply to EVERY line item except themselves obvs
-- 					 UNION ALL
-- 					 SELECT *
-- 					 FROM parent_discounts
-- 					 WHERE is_percent = FALSE)
SELECT *
FROM subtotal
WHERE ORDER_ID_EDW IN ('G3346515', 'SG-91785')
