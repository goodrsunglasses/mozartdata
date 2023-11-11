--- 2023 ACTUAL
WITH
actual AS
(
  SELECT
    '2023 - Actual' AS budget_version,
    ga.account_number,
    ga.account_id_ns,
    gt.posting_period,
    gt.channel,
    sum(gt.credit_amount) - sum(gt.debit_amount) AS amount
  FROM fact.gl_transaction gt
  INNER JOIN draft_dim.gl_account ga ON ga.account_id_ns = gt.account_id_ns
  WHERE gt.posting_period IN ('Jan 2023', 'Feb 2023', 'Mar 2023', 'Apr 2023', 'May 2023', 'Jun 2023', 'Jul 2023', 'Aug 2023', 'Sep 2023')
    AND posting_flag = true
    AND ga.account_number >= 4000 AND ga.account_number < 5000
  GROUP BY ga.account_number, ga.account_id_ns, gt.channel, gt.posting_period
),

--- 2022 ACTUAL
actual_2022 AS
(
  SELECT
    '2022 - Actual' AS budget_version,
    ga.account_number,
    ga.account_id_ns,
    gt.posting_period,
    gt.channel,
    sum(gt.credit_amount) - sum(gt.debit_amount) AS amount
  FROM fact.gl_transaction gt
  INNER JOIN draft_dim.gl_account ga ON ga.account_id_ns = gt.account_id_ns
  WHERE gt.posting_period IN ('Jan 2022', 'Feb 2022', 'Mar 2022', 'Apr 2022', 'May 2022', 'Jun 2022', 'Jul 2022', 'Aug 2022', 'Sep 2022', 'Oct 2022' , 'Nov 2022', 'Dec 2022')
    AND posting_flag = true
    AND ga.account_number >= 4000 AND ga.account_number < 5000
  GROUP BY ga.account_number, ga.account_id_ns, gt.channel, gt.posting_period
),

--- BUDGET
budget AS
(
  SELECT
    gb.budget_version,
    ga.account_number,
    gb.account_id_ns,
    gb.posting_period,
    gb.channel,
    gb.budget_amount
  FROM fact.gl_budget gb
  INNER JOIN draft_dim.gl_account ga ON ga.account_id_ns = gb.account_id_ns
    AND ga.account_number >= 4000 AND ga.account_number < 5000
)

SELECT
  *
FROM actual a
UNION
SELECT
  *
FROM budget b
UNION
SELECT
  *
FROM actual_2022 a22;