SELECT
  project as payroll_project,
  total as payroll_total,
  created_at as payroll_date,
  credit.description as credit_description,
  credit.amount as credit_amount,
  credit.posting_date as credit_date
FROM
  google_sheets.payroll_import payroll 
left outer join google_sheets.credit_card_import credit on abs(credit.amount) = abs(payroll.total)
order by payroll_total desc