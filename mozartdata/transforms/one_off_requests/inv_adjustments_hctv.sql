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
    UNION ALL
    SELECT
      'year' AS period_type,
      'Jan ''24-May ''24' AS period,
      '2024-01-01' AS period_start_date,
      '2024-05-31' AS period_end_date
  )
SELECT
  iid.transaction_id_ns,
  iid.transaction_number_ns,
  iid.record_type,
  iid.channel,
  iid.location_id_ns,
  iid.location_name,
  iid.transaction_created_date_pst,
  iid.item_id_ns,
  iid.sku,
  iid.plain_name,
  iid.quantity,
  period,
  sum(gt.net_amount) net_amount
FROM
  fact.netsuite_inventory_item_detail iid
INNER JOIN
  periods
  on iid.transaction_created_date_pst between period_start_date and period_end_date
LEFT JOIN
  fact.gl_transaction gt
  ON iid.transaction_id_ns = gt.transaction_id_ns
  AND iid.transaction_line_id_ns = gt.transaction_line_id_ns
  AND gt.posting_flag
WHERE
  iid.record_type = 'inventoryadjustment'
GROUP BY
  iid.transaction_id_ns,
  iid.transaction_number_ns,
  iid.record_type,
  iid.channel,
  iid.location_id_ns,
  iid.location_name,
  iid.transaction_created_date_pst,
  iid.item_id_ns,
  iid.sku,
  iid.plain_name,
  iid.quantity,
  period