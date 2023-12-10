SELECT
  order_id_edw,
  channel,
  transaction_created_timestamp_pst
FROM
  fact.order_line
WHERE
  record_type = 'cashrefund'