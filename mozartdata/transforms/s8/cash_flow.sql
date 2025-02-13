/*with date_lag as (
  select   
  *,
  dateadd(month, -1, period_start_date) AS lagged_date,
  from   fact.gl_balances b
)
*/
with  lag as 
  (
  SELECT
  posting_period,
--  dateadd(month, -1 period_start_date) AS posting_period_date,
  period_start_date AS posting_period_date,
  sum(  CASE     WHEN account_number LIKE '10%' THEN current_period_amount    END  ) AS cash,
  sum(  CASE     WHEN account_number LIKE '1100' THEN current_period_amount  END  ) AS receivables,
  sum(  CASE     WHEN account_number LIKE '2000' THEN current_period_amount  END  ) AS payables,
  sum(  CASE     WHEN account_number LIKE '12%' THEN current_period_amount  END  ) AS inventory,
  sum(  CASE     WHEN account_number LIKE '10%' or  
                  account_number LIKE '11%' or
                  account_number LIKE '12%' or
                  account_number LIKE '13%' THEN current_period_amount  END  ) AS current_assets,
  sum(  CASE     WHEN  (account_number LIKE '11%' 
                        or  account_number LIKE '13%')
                        and account_number not in ('1100')  THEN current_period_amount  END  ) AS other_current_assets,
  sum(  CASE     WHEN  (account_number LIKE '17%' or  
                        account_number LIKE '18%') THEN current_period_amount  END  ) AS other_assets,
  sum(  CASE     WHEN (account_number LIKE '20%' and account_number != '2000') or 
                  account_number LIKE '21%' or
                  account_number LIKE '22%' or
                  account_number LIKE '23%' or
                  account_number LIKE '24%' or
                  account_number = '2601' 
                   THEN current_period_amount END  ) AS other_current_liabilities,
  sum(  CASE     WHEN account_number LIKE '2602' THEN current_period_amount  END  ) AS lt_liabilities,
  sum(  CASE     WHEN (account_number LIKE '20%' and account_number != '2000') or 
                  account_number LIKE '21%' or
                  account_number LIKE '23%' or
                  account_number LIKE '24%' or
                  account_number = '2601' 
                   THEN current_period_amount END  ) AS other_current_liabilities_wo_stp,
  sum(  CASE     WHEN account_number LIKE '22%' THEN current_period_amount  END  ) AS sales_tax_payable,
  quarter(posting_period_date) as quarter,
  sum(  CASE     WHEN account_number LIKE '15%' or  
                  account_number LIKE '16%'THEN current_period_amount  END  ) AS PPE,
  sum(  CASE     WHEN account_number LIKE '10%' THEN current_period_amount  END  ) AS cash_casheq,
  sum(  CASE     WHEN account_number LIKE '35%'  THEN current_period_amount END  ) AS equity,
  sum(  CASE     WHEN account_number like '4%' or 
                      account_number like '5%' or 
                      account_number like '6%' or 
                      account_number like '7%' or 
                      account_number like '8%'   THEN current_period_amount END  ) AS net_income,
  sum(  CASE     WHEN account_number between 4000 and 8999 THEN current_period_amount END  ) AS net_income_2
FROM
  fact.gl_balances b
--  left join date_lag using (period_start_date, account_number, current_period_amount)
where posting_period = 'Jan 2025'                  -- for qc
GROUP BY
  1,
  2
ORDER BY
  2 desc
  )
select * from lag
  ---------
/*
, current as (
  
)
select 
current.net_income - lag.net_income as net_income 
from 
  select * from lag 
  union all 
  select * from current 
*/