SELECT
  table_schema,
  table_name,
  lower(column_name) column_name
FROM
  information_schema.columns
WHERE
  table_schema in ('FACT','DIM')
ORDER BY
  table_schema,table_name, ordinal_position