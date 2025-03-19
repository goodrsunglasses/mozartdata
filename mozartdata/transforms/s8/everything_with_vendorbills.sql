WITH
  bills_order_numbers AS (
    SELECT DISTINCT
      order_id_edw
    FROM
      fact.gl_transaction
    WHERE
      record_type = 'vendorbill'
      AND posting_period LIKE '%2024'
  )
  ----- memo from IR but doesn't have the same goodr order number : if IR has the weird goodr po number, then pull the memo in those IRs find matching memo in FP invoices (vendorbills )
,
  irs AS (                                         --- item receipts
    SELECT DISTINCT
      gt.order_id_edw,
      gt.memo
    FROM
      fact.gl_transaction gt
      INNER JOIN bills_order_numbers USING (order_id_edw)
    WHERE
      record_type = 'itemreceipt'
      AND posting_period LIKE '%2024'
  ),
  vbs AS (                                         -- vendorbills
    SELECT DISTINCT
      i.order_id_edw,
      t.record_type,
      t.memo AS vb_memo,
      i.memo AS ir_memo,
      t.transaction_id_ns
    FROM
      irs i
      inner JOIN fact.gl_transaction t ON t.memo LIKE '%' || i.memo || '%'
          AND t.record_type = 'vendorbill'
          AND posting_period LIKE '%2024'
--    where i.order_id_edw = 'LAS-TROP122023-4.8K-1'
  )

SELECT DISTINCT
  order_id_edw,
  posting_period,
  transaction_number_ns,
  transaction_id_ns,
  record_type,
  account_number,
  sum(credit_amount),
  sum(debit_amount),
  posting_flag,
  memo
FROM
  fact.gl_transaction
  INNER JOIN bills_order_numbers USING (order_id_edw) 
--WHERE
--  order_id_edw = 'LAS-TROP122023-4.8K-1'
GROUP BY
  ALL

union all 

SELECT DISTINCT
  vbs.order_id_edw,          --- the item reciept order_id_edw for joining in the pivot tables 
  posting_period,
  transaction_number_ns,
  transaction_id_ns,
  record_type,
  account_number,
  sum(credit_amount),
  sum(debit_amount),
  posting_flag,
  memo
FROM
  fact.gl_transaction
  INNER JOIN vbs USING (transaction_id_ns) 
GROUP BY
  ALL

  
ORDER BY
  order_id_edw,
  transaction_id_ns