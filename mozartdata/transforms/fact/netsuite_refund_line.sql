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
	   SUM(quantity)        total_quantity,
	   SUM(rate)            total_rate,
	   SUM(RATEAMOUNT)      total_rateamount,
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