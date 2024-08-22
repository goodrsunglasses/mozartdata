SELECT
  gl.order_id_ns,
  gl.memo,
  transaction_date_pst,
  transaction_number_ns,
  record_type,
  net_amount AS netsuite_amount,
  shop.total_price shopify_amount,
  round(abs(net_amount) - abs(total_price), 2) AS abs_diff
FROM
  fact.gl_transaction gl
  LEFT OUTER JOIN specialty_shopify."ORDER" shop ON shop.name = gl.memo
WHERE
  transaction_line_id_ns = 0
  AND gl.record_type IN ('cashsale', 'cashrefund', 'invoice')
  AND abs_diff != 0
  AND net_amount IS NOT NULL
  AND transaction_date_pst > '2024-05-01'