-- Calculate aggregated values for September 1, 2022, to September 30, 2022
WITH sept_2022 AS (
  SELECT
    DATE_TRUNC('DAY', timestamp_transaction_pst) AS transaction_date,
    DAYOFWEEK(transaction_date) AS day_of_week_2022,
    SUM(quantity_sold) AS quantity_sold_2022,
    SUM(profit_gross) AS profit_gross_2022,
    SUM(amount_total) AS amount_total_2022
  FROM dim.orders
  WHERE DATE_TRUNC('DAY', timestamp_transaction_pst) BETWEEN '2022-09-01' AND '2022-09-30'
  GROUP BY transaction_date, day_of_week_2022
),

-- Calculate aggregated values for September 1, 2023, to September 30, 2023
sept_2023 AS (
  SELECT
    DATE_TRUNC('DAY', timestamp_transaction_pst) AS transaction_date,
    DAYOFWEEK(transaction_date) AS day_of_week_2023,
    SUM(quantity_sold) AS quantity_sold_2023,
    SUM(profit_gross) AS profit_gross_2023,
    SUM(amount_total) AS amount_total_2023
  FROM dim.orders
  WHERE DATE_TRUNC('DAY', timestamp_transaction_pst) BETWEEN '2023-09-01' AND '2023-09-30'
  GROUP BY transaction_date, day_of_week_2023
)

-- Combine and compare the results
SELECT
  COALESCE(sept_2022.transaction_date, sept_2023.transaction_date) AS transaction_date,
  sept_2022.day_of_week_2022,
  sept_2023.day_of_week_2023,
  sept_2022.quantity_sold_2022,
  sept_2023.quantity_sold_2023,
  sept_2022.profit_gross_2022,
  sept_2023.profit_gross_2023,
  sept_2022.amount_total_2022,
  sept_2023.amount_total_2023
FROM sept_2022
FULL JOIN sept_2023
ON sept_2022.transaction_date = sept_2023.transaction_date
ORDER BY transaction_date;