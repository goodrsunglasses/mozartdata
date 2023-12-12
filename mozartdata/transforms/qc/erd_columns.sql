SELECT
  lower(column_name)
FROM
  information_schema.columns
WHERE
  table_name = 'ORDER_ITEM_DETAIL'
  AND table_schema = 'FACT'
ORDER BY
  ordinal_position asc