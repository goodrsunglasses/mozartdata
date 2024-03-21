SELECT
  order_id_edw, MAX(
    CASE
      WHEN record_type = 'salesorder'
      AND transaction_status_ns LIKE '%Billed%' THEN 1
      ELSE 0
    END
  ) AS SalesOrderFlag,
  MAX(
    CASE
      WHEN record_type = 'cashsale'
      AND transaction_status_ns like '%Not Deposited%' THEN 1
      ELSE 0
    END
  ) AS CashSaleFlag from fact.order_line where order_id_edw = 'CS-WQT-SG-65209'

  group by order_id_edw
-- SELECT
--   order_id_edw,
--   transaction_id_ns,
--   transaction_number_ns,
--   record_type,
--   transaction_status_ns
-- FROM
--   fact.order_line
-- WHERE
--   AND transaction_date < (CURRENT_DATE() -2) -- 2 day offset just in case