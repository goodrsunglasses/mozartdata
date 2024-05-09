WITH actuals AS (
    SELECT
        posting_period,
        to_date(posting_period, 'MON YYYY') AS posting_period_date,
        sum(CASE WHEN account_number LIKE '4%' THEN net_amount END) AS revenue,
        sum(CASE WHEN account_number LIKE '5%' THEN net_amount END) AS cogs,
        sum(CASE WHEN account_number LIKE '6%' OR account_number LIKE '7%' THEN net_amount END) AS opex,
        (revenue - cogs - opex) AS net_income,
        sum(CASE WHEN account_number LIKE '60%' THEN net_amount END) AS fulfillment,
        sum(CASE WHEN account_number LIKE '61%' THEN net_amount END) AS product_dev,
        sum(CASE WHEN account_number LIKE '63%' THEN net_amount END) AS sales_and_marketing,
        sum(CASE WHEN account_number LIKE '70%' THEN net_amount END) AS labor,
        sum(CASE WHEN account_number LIKE '7%' AND account_number NOT LIKE '70%' THEN net_amount END) AS g_and_a,
        (revenue - cogs) / revenue AS gross_margin,
        (net_income / revenue) AS net_margin
    FROM
        fact.gl_transaction gt
    WHERE
        posting_flag = 'true'
    and to_date(posting_period, 'MON YYYY') >='2024-01-01'
    GROUP BY
        posting_period, to_date(posting_period, 'MON YYYY')
),
budget AS (
    SELECT
        posting_period,
        to_date(posting_period, 'MON YYYY') AS posting_period_date,
        sum(CASE WHEN account_number LIKE '4%' THEN budget_amount END) AS revenue,
        sum(CASE WHEN account_number LIKE '5%' THEN budget_amount END) AS cogs,
        sum(CASE WHEN account_number LIKE '6%' OR account_number LIKE '7%' THEN budget_amount END) AS opex,
        (revenue - cogs - opex) AS net_income,
        sum(CASE WHEN account_number LIKE '60%' THEN budget_amount END) AS fulfillment,
        sum(CASE WHEN account_number LIKE '61%' THEN budget_amount END) AS product_dev,
        sum(CASE WHEN account_number LIKE '63%' THEN budget_amount END) AS sales_and_marketing,
        sum(CASE WHEN account_number LIKE '70%' THEN budget_amount END) AS labor,
        sum(CASE WHEN account_number LIKE '7%' AND account_number NOT LIKE '70%' THEN budget_amount END) AS g_and_a,
        (revenue - cogs) / revenue AS gross_margin,
        (net_income / revenue) AS net_margin,
        budget_version
    FROM
        fact.gl_budget gb
    WHERE
       to_date(posting_period, 'MON YYYY') >='2024-01-01'
    GROUP BY
        posting_period, to_date(posting_period, 'MON YYYY'), budget_version
)
SELECT
    *,
    SUM(revenue) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS revenue_ytd,
    SUM(cogs) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cogs_ytd,
    SUM(opex) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS opex_ytd,
    SUM(net_income) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS net_income_ytd,
    SUM(fulfillment) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS fulfillment_ytd,
    SUM(product_dev) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS product_dev_ytd,
    SUM(sales_and_marketing) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sales_and_marketing_ytd,
    SUM(labor) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS labor_ytd,
    SUM(g_and_a) OVER (PARTITION BY budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS g_and_a_ytd,
    (revenue_ytd - cogs_ytd) / revenue_ytd AS gross_margin_ytd,
    (net_income_ytd / revenue_ytd) AS net_margin_ytd,
FROM (
    SELECT
        *,
        'actual' AS budget_version
    FROM
        actuals

    UNION ALL

    SELECT
        *
    FROM
        budget
) AS combined_data
order by
budget_version, posting_period_date