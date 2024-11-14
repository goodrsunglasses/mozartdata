SELECT
  posting_period,
  period_start_date AS posting_period_date,
  sum(  CASE     WHEN account_number LIKE '10%' THEN ending_balance    END  ) AS cash,
  sum(  CASE     WHEN account_number LIKE '11%' THEN ending_balance  END  ) AS receivables,
  sum(  CASE     WHEN account_number LIKE '20%' THEN ending_balance  END  ) AS payables,
  sum(  CASE     WHEN account_number LIKE '12%' THEN ending_balance  END  ) AS inventory,
  sum(  CASE     WHEN account_number LIKE '10%' or  
                  account_number LIKE '11%' or
                  account_number LIKE '12%' or
                  account_number LIKE '13%' THEN ending_balance  END  ) AS current_assets,
  sum(  CASE     WHEN account_number LIKE '20%' or  
                  account_number LIKE '21%' or
                  account_number LIKE '22%' or
                  account_number LIKE '23%' or
                  account_number LIKE '24%' or
                  account_number = '2601' THEN ending_balance END  ) AS current_liabilities,
  current_assets - current_liabilities as net_working_capital,
  current_assets / current_liabilities as current_ratio,
  (cash + receivables) / current_liabilities as quick_ratio,
  cash / current_liabilities as cash_ration,
  quarter(posting_period_date) as quarter,
  sum(  CASE     WHEN account_number LIKE '15%' or  
                  account_number LIKE '16%' or
                  account_number LIKE '17%' or
                  account_number = '1820' THEN ending_balance  END  ) AS PPE,
  sum(  CASE     WHEN account_number LIKE '10%' THEN ending_balance  END  ) AS cash_casheq,
  sum(  CASE     WHEN account_number = '2000' THEN ending_balance  END  ) AS AP,
  sum(  CASE     WHEN account_number LIKE '202%' or  
                  account_number LIKE '21%' or
                  account_number LIKE '22%' or
                  account_number LIKE '23%' or
                  account_number LIKE '24%' or
                  account_number = '2601' or
                  account_number = '2602' THEN ending_balance END  ) AS other_liabilities,
  sum(  CASE     WHEN account_number LIKE '13%' or  
                  account_number LIKE '18%'  THEN ending_balance END  ) AS other,
  sum(  CASE     WHEN account_number LIKE '35%'  THEN ending_balance END  ) AS equity
FROM
  fact.gl_balances b
GROUP BY
  1,
  2
ORDER BY
  2 desc