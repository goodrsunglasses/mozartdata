-- CREATE OR REPLACE TABLE fact.netsuite_refund_line
-- 	COPY GRANTS AS
SELECT transaction_id_ns,

FROM fact.netsuite_refund_item_detail