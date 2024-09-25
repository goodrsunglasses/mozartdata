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
SELECT distinct
  payroll.id AS external_ID,
  6350 AS ACCOUNT,
  302 AS account_id,
  payroll.total AS debit,
  NULL AS credit,
  project AS memo,
  'Creative Herd : Content Production' AS departement,
  6 AS department_id,
  NULL AS payee,
  NULL AS payee_id,
  'Photoshoot' AS class,
  42 AS class_id,
  created_at AS payroll_date,
  credit.description AS credit_description,
  coalesce(count1.counter,count2.counter) dup_check
FROM
  google_sheets.payroll_import payroll
  LEFT OUTER JOIN google_sheets.credit_card_import credit ON abs(credit.amount) = abs(payroll.total)
  left outer join unique_counter count1 on abs(count1.total)  = abs(payroll.total)
  left outer join unique_counter count2 on abs(count2.total)  = abs(credit.amount)
  where dup_check is not null
union all 
SELECT distinct
  payroll.id AS external_ID,
  6350 AS ACCOUNT,
  302 AS account_id,
  payroll.total AS debit,
  NULL AS credit,
  project AS memo,
  'Creative Herd : Content Production' AS departement,
  6 AS department_id,
  NULL AS payee,
  NULL AS payee_id,
  'Photoshoot' AS class,
  42 AS class_id,
  created_at AS payroll_date,
  null AS credit_description,
  count1.counter as  dup_check
FROM
  google_sheets.payroll_import payroll
  left outer join unique_counter count1 on abs(count1.total)  = abs(payroll.total)
  where dup_check is null
ORDER BY
  external_id desc