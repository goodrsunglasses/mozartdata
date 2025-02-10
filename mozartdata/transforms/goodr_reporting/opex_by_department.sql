WITH
  dept_map AS (
    SELECT DISTINCT
      (department_id_ns),
      department,
      case 
          when department_id_ns in (25,18331,12,53241) then 'money'
          when department_id_ns in (24,4,53239,18333,8) then 'retail'
          when department_id_ns in (16,20,22,6,21) then 'creative'
          when department_id_ns in (46536,18,2,19,1,53242,3) then 'consumer'
          when department_id_ns in (9,53138,23,11,18332,14,17) then 'ops'
          when department_id_ns in (26,53137,27,13,28,23334,29) then 'people'
          else 'unknown' end as herd
    FROM
      fact.gl_transaction gt
    WHERE
      posting_flag = 'true'
      AND to_date(posting_period, 'MON YYYY') >= '2022-01-01'
      AND (account_number LIKE '6%' OR account_number LIKE '7%'      ) --- opex accounts
    GROUP BY
      ALL
  )
, actuals as 
  (
  SELECT
  posting_period,
  to_date(posting_period, 'MON YYYY') AS posting_period_date,
  concat(right(posting_period, 4), ' - Actual') AS budget_version,
    sum( CASE  WHEN herd = 'money' THEN net_amount    END  ) AS money,
    sum( CASE  WHEN herd = 'retail' THEN net_amount    END  ) AS retail,
    sum( CASE  WHEN herd = 'creative' THEN net_amount    END  ) AS creative,
    sum( CASE  WHEN herd = 'ops' THEN net_amount    END  ) AS ops,
    sum( CASE  WHEN herd = 'people' THEN net_amount    END  ) AS people,
    sum( CASE  WHEN herd = 'unknown' THEN net_amount    END  ) AS unknown
FROM
  fact.gl_transaction gt
  left join dept_map using (department_id_ns)
WHERE
  posting_flag = 'true'
  AND to_date(posting_period, 'MON YYYY') >= '2022-01-01'
      and ((account_number LIKE '6%'      
      AND right(posting_period, 4) > 2024) OR (account_number LIKE '6%'     AND right(posting_period, 4) <= 2024     
      AND account_number NOT IN (6005, 6015, 6016, 6020)) OR (account_number LIKE '7%'))   ---- opex accounts 
GROUP BY all
  )
, budget as (
  SELECT
  posting_period,
  to_date(posting_period, 'MON YYYY') AS posting_period_date,
  budget_version,
    sum( CASE  WHEN herd = 'money' THEN budget_amount    END  ) AS money,
    sum( CASE  WHEN herd = 'retail' THEN budget_amount    END  ) AS retail,
    sum( CASE  WHEN herd = 'creative' THEN budget_amount    END  ) AS creative,
    sum( CASE  WHEN herd = 'ops' THEN budget_amount    END  ) AS ops,
    sum( CASE  WHEN herd = 'people' THEN budget_amount    END  ) AS people,
    sum( CASE  WHEN herd = 'unknown' THEN budget_amount    END  ) AS unknown
FROM
  fact.gl_budget gb
  left join dept_map using (department_id_ns)
WHERE
  to_date(posting_period, 'MON YYYY') >= '2022-01-01'
      and ((account_number LIKE '6%'      
      AND right(posting_period, 4) > 2024) OR (account_number LIKE '6%'     
      AND right(posting_period, 4) <= 2024     AND account_number NOT IN (6005, 6015, 6016, 6020)) OR (account_number LIKE '7%')) ---- opex accounts 
GROUP BY all
)
select 
  *,
  SUM(money) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS money_ytd,
  SUM(retail) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS retail_ytd,
  SUM(creative) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS creative_ytd,
  SUM(ops) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ops_ytd,
  SUM(people) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS people_ytd,
  SUM(unknown) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS unknown_ytd,
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