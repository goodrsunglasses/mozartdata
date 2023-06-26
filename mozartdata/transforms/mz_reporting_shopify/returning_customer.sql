-- Calculates the ratio of new customers and repeat customers to total customers rounded up to 4 decimal places for the past 3 months.

SELECT
    num_months_ago,
    ROUND(COUNT(CASE WHEN new_vs_repeat = 'new' THEN 1 END) / COUNT(*),4) AS new,  
    ROUND(COUNT(CASE WHEN new_vs_repeat = 'repeat' THEN 1 END ) / COUNT(*),4) AS repeat
    
  FROM
    mz_reporting_shopify.orders

  WHERE
    num_months_ago < 3
  
  GROUP BY
    num_months_ago