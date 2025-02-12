with actuals as 
  (
  SELECT
  posting_period,
  to_date(posting_period, 'MON YYYY') AS posting_period_date,
  concat(right(posting_period, 4), ' - Actual') AS budget_version,
  sum( net_amount ) AS payroll,
FROM
  fact.gl_transaction gt
WHERE
  posting_flag = 'true'
  AND to_date(posting_period, 'MON YYYY') >= '2022-01-01'
  and account_number in (7010, 7015, 7020, 7030, 7040, 7050)   ---- payroll accounts
GROUP BY all
  )
, budget as (
  SELECT
  posting_period,
  to_date(posting_period, 'MON YYYY') AS posting_period_date,
  concat(right(posting_period, 4), ' - Actual') AS budget_version,
  sum( budget_amount ) AS payroll,
FROM
  fact.gl_budget gb
WHERE
  to_date(posting_period, 'MON YYYY') >= '2022-01-01'
  and account_number in (7010, 7015, 7020, 7030, 7040, 7050)   ---- payroll accounts
GROUP BY all
)
select 
  *,
  SUM(payroll) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS payroll_ytd,
  quarter(posting_period_date) as quarter,
  date(date_trunc(quarter, posting_period_date)) as quarter_date,
  date_part(year, posting_period_date) as year
from 
  (
    select * from actuals 
    union all 
    select * from budget
  )
  as combined_data
order by
posting_period_date desc, budget_version