WITH ss_qty AS (SELECT fulfillment_id_edw,
					   order_id_edw,
					   sku,
					   ITEM_ID,
					   quantity
				FROM fact.fulfillment_item_detail
				WHERE source = 'Shipstation'),
	 stord_qty AS (SELECT fulfillment_id_edw,
						  order_id_edw,
						  sku,
						  ITEM_ID,
						  quantity
				   FROM fact.fulfillment_item_detail
				   WHERE source = 'Stord'),
	 netsuite_qty AS (SELECT fulfillment_id_edw, order_id_edw, sku, ITEM_ID, quantity
					  FROM fact.fulfillment_item_detail
					  WHERE source = 'Netsuite')
SELECT fulfillment_id_edw,
	   order_id_edw
FROM fact.FULFILLMENT_ITEM_DETAIL


WHERE ORDER_ID_EDW LIKE '%CS-LST-SD-G2501679%'