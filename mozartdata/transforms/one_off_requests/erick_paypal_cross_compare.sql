SELECT
  pay.id,
  pay.initiation_date,
  pay.updated_date,
  pay.currency_code,
  pay.amount,
  pay.invoice_id,
  gl.order_id_ns,
  gl.transaction_number_ns,
  net_amount,
  round(abs(pay.amount)-abs(gl.net_amount),2) as abs_diff
FROM
  paypal.transaction pay
  LEFT OUTER JOIN fact.gl_transaction gl ON gl.memo = pay.id
WHERE
  transaction_line_id_ns = 0
  AND record_type IN ('cashsale', 'cashrefund', 'invoice')
  and abs_diff != 0