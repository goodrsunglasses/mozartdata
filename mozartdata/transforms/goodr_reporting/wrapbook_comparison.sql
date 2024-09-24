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
  total AS debit,
  NULL AS credit,
  project AS memo,
  'Creative Herd : Content Production' AS departement,
  6 AS department_id,
  NULL AS payee,
  NULL AS payee_id,
  'Photoshoot' AS class,
  42 AS class_id,
  created_at AS payroll_date,
  credit.description AS credit_description
FROM
  google_sheets.payroll_import payroll
  LEFT OUTER JOIN google_sheets.credit_card_import credit ON abs(credit.amount) = abs(payroll.total)
ORDER BY
  external_id desc