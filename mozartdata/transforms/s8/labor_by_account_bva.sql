with actuals as (
  SELECT
    posting_period,
    to_date(posting_period, 'MON YYYY') AS posting_period_date,
    concat(right(posting_period, 4), ' - Actual') AS budget_version,
    sum(CASE WHEN account_number = 7010 THEN net_amount END) AS wages,
    sum(CASE WHEN account_number = 7015 THEN net_amount END) AS bonuses,
    sum(CASE WHEN account_number = 7020 THEN net_amount END) AS tax,
    sum(CASE WHEN account_number = 7030 THEN net_amount END) AS benefits,
    sum(CASE WHEN account_number = 7035 THEN net_amount END) AS retirement,
    sum(CASE WHEN account_number = 7040 THEN net_amount END) AS peo,
    sum(CASE WHEN account_number = 7050 THEN net_amount END) AS comp,
    sum(CASE WHEN account_number = 7005 THEN net_amount END) AS consulting
FROM
  fact.gl_transaction
WHERE
  posting_flag
  AND to_date(posting_period, 'MON YYYY') >= '2022-01-01'
group by all
  )
, budget as (
    SELECT
    posting_period,
    to_date(posting_period, 'MON YYYY') AS posting_period_date,
    budget_version,
    sum(CASE WHEN account_number = 7010 THEN budget_amount END) AS wages,
    sum(CASE WHEN account_number = 7015 THEN budget_amount END) AS bonuses,
    sum(CASE WHEN account_number = 7020 THEN budget_amount END) AS tax,
    sum(CASE WHEN account_number = 7030 THEN budget_amount END) AS benefits,
    sum(CASE WHEN account_number = 7035 THEN budget_amount END) AS retirement,
    sum(CASE WHEN account_number = 7040 THEN budget_amount END) AS peo,
    sum(CASE WHEN account_number = 7050 THEN budget_amount END) AS comp,
    sum(CASE WHEN account_number = 7005 THEN budget_amount END) AS consulting
  from 
    fact.gl_budget gb
  WHERE
  to_date(posting_period, 'MON YYYY') >= '2022-01-01'
  group by all 
)
select 
  *,
  SUM(wages) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS wages_ytd,
  SUM(bonuses) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS bonuses_ytd, 
  SUM(tax) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS tax_ytd,
  SUM(benefits) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS benefits_ytd,
  SUM(retirement) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS retirement_ytd,
  SUM(peo) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS peo_ytd,
  SUM(comp) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS comp_ytd,
  SUM(consulting) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS consulting_ytd,
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