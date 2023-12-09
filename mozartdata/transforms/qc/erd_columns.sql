SELECT
  lower(column_name)
FROM
  information_schema.columns
WHERE
  table_name = 'CUSTOMER_SHOPIFY_MAP'
  AND table_schema = 'FACT'
ORDER BY
  ordinal_position asc