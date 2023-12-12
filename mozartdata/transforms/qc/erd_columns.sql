SELECT
  lower(column_name) as ORDER_ITEM_DETAIL
FROM
  information_schema.columns
WHERE
  table_name = 'ORDER_ITEM_DETAIL'
  AND table_schema = 'FACT'
ORDER BY
  ordinal_position asc