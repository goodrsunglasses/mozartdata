-- CREATE OR REPLACE TABLE fact.netsuite_refund_line
-- 	COPY GRANTS AS
SELECT transaction_id_ns,
	   order_id_edw,
	   channel,
	   customer_category,
	   transaction_created_date_pst,
	   transaction_date,
	   transaction_number_ns,
	   memo,
	   SUM(quantity)       as quantity_refunded,
	   SUM(rate)            as rate_refunded,
	   SUM(RATEAMOUNT)     as rate_amount_refunded,
	   ARRAY_AGG(line_memo) line_memos

FROM fact.netsuite_refund_item_detail
GROUP BY transaction_id_ns,
		 order_id_edw,
		 channel,
		 customer_category,
		 transaction_created_date_pst,
		 transaction_date,
		 transaction_number_ns,
		 memo