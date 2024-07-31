WITH
  periods AS (
    SELECT
      'year' AS period_type,
      'Jan ''22-Dec ''22' AS period,
      '2022-01-01' AS period_start_date,
      '2022-12-31' AS period_end_date
    UNION ALL
    SELECT
      'year' AS period_type,
      'Jan ''23-Dec ''23' AS period,
      '2023-01-01' AS period_start_date,
      '2023-12-31' AS period_end_date
    UNION ALL
    SELECT
      'month' AS period_type,
      'Jun ''23' AS period,
      '2023-06-01' AS period_start_date,
      '2023-06-30' AS period_end_date
    UNION ALL
    SELECT
      'month' AS period_type,
      'Jun ''24' AS period,
      '2024-06-01' AS period_start_date,
      '2024-06-30' AS period_end_date
  )
SELECT
  transaction_id_ns,
  transaction_number_ns,
  record_type,
  channel,
  location_id_ns,
  location_name,
  transaction_created_date_pst,
  sku,
  plain_name,
  quantity
FROM
  fact.inventory_item_detail
WHERE
  record_type = 'inventoryadjustment'