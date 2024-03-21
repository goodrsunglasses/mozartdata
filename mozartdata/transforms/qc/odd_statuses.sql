WITH
  status_checker AS ( --not incredibly sure what structure this will take yet, but I'm trying to build fo scaleability so I'm keeping it general, if alot of these pop up they could be swapped to be catch-all booleans based on status
    --for examnple cs_not_deposited, so_billed, etc...
    SELECT
      order_id_edw,
      MAX(
        CASE
          WHEN record_type = 'salesorder'
          AND transaction_status_ns LIKE '%Billed%' THEN 1
          ELSE 0
        END
      ) AS SalesOrderFlag,
      MAX(
        CASE
          WHEN record_type = 'cashsale'
          AND transaction_status_ns LIKE '%Not Deposited%' THEN 1
          ELSE 0
        END
      ) AS CashSaleFlag
    FROM
      fact.order_line
    GROUP BY
      order_id_edw
  )
SELECT
  orders.order_id_edw,
  booked_date,
  channel,
  CASE
    WHEN SalesOrderFlag = 1
    AND CashSaleFlag = 1 THEN TRUE
    ELSE FALSE
  END AS not_deposited_flag
FROM
  fact.orders orders
  LEFT OUTER JOIN status_checker ON status_checker.order_id_edw = orders.order_id_edw
WHERE
  booked_date < (CURRENT_DATE() -2) -- 2 day offset just in case
and not_deposited_flag = true