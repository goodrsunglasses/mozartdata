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
  gt.transaction_line_id,
  gt.transaction_id_ns,
  gt.transaction_number_ns,
  gt.record_type,
  gt.channel,
  gt.transaction_date,
  gt.item_id_ns,
  p.sku,
  p.display_name,
--  gt.quantity,
  period,
  sum(gt.net_amount) net_amount,
  gt.account_number,
  ga.account_display_name
FROM
  fact.gl_transaction gt
INNER JOIN
  periods
  on gt.transaction_date between period_start_date and period_end_date
left join 
    dim.product p on p.item_id_ns = gt.item_id_ns
left join 
  dim.gl_account ga on gt.account_id_ns = ga.account_id_ns
WHERE
  gt.record_type = 'inventoryadjustment'
  AND gt.posting_flag
GROUP BY
 all