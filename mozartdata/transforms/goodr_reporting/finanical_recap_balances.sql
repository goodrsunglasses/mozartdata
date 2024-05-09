SELECT
  posting_period,
  period_start_date AS posting_period_date,
  sum(  CASE     WHEN account_number LIKE '10%' THEN ending_balance    END  ) AS cash,
  sum(  CASE     WHEN account_number = '1100' THEN ending_balance  END  ) AS receivables,
  sum(  CASE     WHEN account_number LIKE '20%' THEN ending_balance  END  ) AS payables,
  sum(  CASE     WHEN account_number LIKE '10%' or  
                  account_number LIKE '11%' or
                  account_number LIKE '12%' or
                  account_number LIKE '13%' THEN ending_balance  END  ) AS current_assets,
  sum(  CASE     WHEN account_number LIKE '20%' or  
                  account_number LIKE '21%' or
                  account_number LIKE '22%' or
                  account_number LIKE '23%' or
                  account_number LIKE '24%' or
                  account_number = '2601' THEN ending_balance  END  ) AS current_liabilities,
  current_assets - current_liabilities as net_working_capital,
  current_assets / current_liabilities as current_ratio,
  (cash + receivables) / current_liabilities as quick_ratio,
  cash / current_liabilities as cash_ration
FROM
  fact.gl_balances
GROUP BY
  1,
  2
ORDER BY
  2 desc