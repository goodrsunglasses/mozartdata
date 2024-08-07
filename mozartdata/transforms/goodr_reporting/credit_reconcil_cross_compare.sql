SELECT DISTINCT
  transaction_id_ns,
  transaction_number_ns,
  net_amount,
  department,
  transaction_date,
  memo,
  TRIM(SPLIT_PART(value, ':', 1)) AS key,
  TRIM(SPLIT_PART(value, ':', 2)) AS val
FROM
  fact.gl_transaction,
  LATERAL FLATTEN(INPUT => SPLIT(memo, '|')) AS value
WHERE
  transaction_id_ns = 23886919