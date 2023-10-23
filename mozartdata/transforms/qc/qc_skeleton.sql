SELECT LISTAGG(
    'SELECT
      ''' || COLUMN_NAME || ''' AS ColumnName,
      ''' || DATA_TYPE || ''' AS Datatype,
      COUNT(*) AS TotalRows,
      SUM(CASE WHEN ' || COLUMN_NAME || ' IS NULL THEN 1 ELSE 0 END) AS NullCount,
      COUNT(*) - COUNT(DISTINCT ' || COLUMN_NAME || ') AS DuplicateCount
    FROM ' || 'DRAFT_FACT.CUSTOMER_SHOPIFY_MAP',
    ' UNION ALL '
  ) WITHIN GROUP (ORDER BY COLUMN_NAME)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'DRAFT_FACT' AND TABLE_NAME = 'CUSTOMER_SHOPIFY_MAP'