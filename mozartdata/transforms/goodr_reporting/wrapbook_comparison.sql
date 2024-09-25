WITH
  unique_counter AS (
    SELECT
      total,
      count(total) counter
    FROM
      google_sheets.payroll_import
    GROUP BY
      total
    HAVING
      counter = 1
    UNION ALL
    SELECT
      amount,
      count(amount) counter
    FROM
      google_sheets.credit_card_import
    GROUP BY
      amount
    HAVING
      counter = 1
  )
SELECT DISTINCT
  payroll.id AS external_ID,
  6350 AS ACCOUNT,
  302 AS account_id,
  payroll.total AS debit,
  project AS memo,
  'Creative Herd : Content Production' AS departement,
  6 AS department_id,
  NULL AS payee,
  NULL AS payee_ID,
  'Photoshoot' AS class,
  42 AS class_id,
  date(TO_TIMESTAMP(created_at, 'MM/DD/YYYY HH24:MI')) AS payroll_date,
  credit.description AS credit_description,
  NULL AS Address_1,
  NULL AS Address_2,
  NULL AS City,
  NULL AS State,
  NULL AS ZIP,
  coalesce(count1.counter, count2.counter) dup_check
FROM
  google_sheets.payroll_import payroll
  LEFT OUTER JOIN google_sheets.credit_card_import credit ON abs(credit.amount) = abs(payroll.total)
  LEFT OUTER JOIN unique_counter count1 ON abs(count1.total) = abs(payroll.total)
  LEFT OUTER JOIN unique_counter count2 ON abs(count2.total) = abs(credit.amount)
WHERE
  dup_check IS NOT NULL
UNION ALL
SELECT DISTINCT
  payroll.id AS external_ID,
  6350 AS ACCOUNT,
  302 AS account_id,
  payroll.total AS debit,
  project AS memo,
  'Creative Herd : Content Production' AS departement,
  6 AS department_id,
  NULL AS payee,
  NULL AS payee_id,
  'Photoshoot' AS class,
  42 AS class_id,
  date(TO_TIMESTAMP(created_at, 'MM/DD/YYYY HH24:MI')) AS payroll_date,
  NULL AS credit_description,
   NULL AS Address_1,
  NULL AS Address_2,
  NULL AS City,
  NULL AS State,
  NULL AS ZIP,
  count1.counter AS dup_check
FROM
  google_sheets.payroll_import payroll
  LEFT OUTER JOIN unique_counter count1 ON abs(count1.total) = abs(payroll.total)
WHERE
  dup_check IS NULL
ORDER BY
  external_id desc