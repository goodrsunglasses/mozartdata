WITH actuals AS (
    SELECT
        posting_period,
        to_date(posting_period, 'MON YYYY') AS posting_period_date,
        sum(CASE WHEN account_number LIKE '4%' THEN net_amount END) AS revenue,
        sum(CASE WHEN account_number LIKE '5000' THEN net_amount END) AS cogs,
        sum(CASE WHEN account_number LIKE '5100%' THEN net_amount END) AS inv_adj,
        sum(CASE WHEN account_number LIKE '5110' THEN net_amount END) AS royalties,
        sum(CASE WHEN account_number LIKE '5200' THEN net_amount END) AS lcv,
        sum(CASE WHEN account_number in ('5005','6005') THEN net_amount END) AS bank_fees,
        sum(CASE WHEN account_number in ('5015','6015') THEN net_amount END) AS threepl,
        sum(CASE WHEN account_number in ('5016','6016') THEN net_amount END) AS amazon_ful,
        sum(CASE WHEN account_number = '5020' then net_amount
                 WHEN account_number = '6020' and right(posting_period,4) <= 2024 THEN net_amount
                  ELSE 0 END) AS shipping,
 --       sum(CASE WHEN account_number LIKE '5%' THEN net_amount END) AS all_cos_accounts,
        sum(CASE WHEN account_number like '5%' then net_amount
                 WHEN account_number in (6005,6015,6016,6020) and right(posting_period,4) <= 2024 THEN net_amount
                 ELSE 0 end) AS cos,
        sum(CASE WHEN account_number LIKE '6%' AND right(posting_period,4) > 2024 then net_amount
         WHEN account_number LIKE '6%' AND right(posting_period,4) <= 2024 AND account_number not in (6005,6015,6016,6020) then net_amount
         WHEN account_number LIKE '7%' THEN net_amount END) AS opex,
--        (revenue - cos - opex) AS net_income,
       sum(CASE WHEN account_number like '4%' or account_number like '80%' then net_amount
                     when
                      account_number like '5%' or
                      account_number like '6%' or
                      account_number like '7%' or
                      account_number like '85%' THEN net_amount *-1 END) AS net_income,
        sum(CASE WHEN account_number LIKE '60%' AND right(posting_period,4) > 2024 then net_amount
         WHEN account_number LIKE '60%' AND right(posting_period,4) <= 2024 AND account_number not in (6005,6015,6016,6020) then net_amount END) AS fulfillment,
        sum(CASE WHEN account_number LIKE '61%' THEN net_amount END) AS product_dev,
        sum(CASE WHEN account_number LIKE '63%' THEN net_amount END) AS sales_and_marketing,
        sum(CASE WHEN account_number LIKE '70%' THEN net_amount END) AS labor,
        sum(CASE WHEN account_number LIKE '7%' AND account_number NOT LIKE '70%' THEN net_amount END) AS g_and_a,
        (revenue - cos) / revenue AS gross_margin,
        (net_income / revenue) AS net_margin
    FROM
        fact.gl_transaction gt
    WHERE
        posting_flag = 'true'
    and to_date(posting_period, 'MON YYYY') >='2022-01-01'
    GROUP BY
        posting_period, to_date(posting_period, 'MON YYYY')
),
budget AS (
    SELECT
        posting_period,
        to_date(posting_period, 'MON YYYY') AS posting_period_date,
        sum(CASE WHEN account_number LIKE '4%' THEN budget_amount END) AS revenue,
        sum(CASE WHEN account_number LIKE '5000' THEN budget_amount END) AS cogs,
        sum(CASE WHEN account_number LIKE '5100%' THEN budget_amount END) AS inv_adj,
        sum(CASE WHEN account_number LIKE '5110' THEN budget_amount END) AS royalties,
        sum(CASE WHEN account_number LIKE '5200' THEN budget_amount END) AS lcv,
        sum(CASE WHEN account_number in ('5005','6005') THEN budget_amount END) AS bank_fees,
        sum(CASE WHEN account_number in ('5015','6015') THEN budget_amount END) AS threepl,
        sum(CASE WHEN account_number in ('5016','6016') THEN budget_amount END) AS amazon_ful,
        sum(CASE WHEN account_number = '5020' then budget_amount
                 WHEN account_number = '6020' and right(posting_period,4) <= 2024 THEN budget_amount
                  ELSE 0 END) AS shipping,
--        sum(CASE WHEN account_number LIKE '5%' THEN budget_amount END) AS all_cos_accounts,
        sum(CASE WHEN account_number like '5%' then budget_amount
                 WHEN account_number in (6005,6015,6016,6020) and right(posting_period,4) <= 2024 THEN budget_amount
                 ELSE 0 end) AS cos,
        sum(CASE WHEN account_number LIKE '6%' OR account_number LIKE '7%' THEN budget_amount END) AS opex,
--        (revenue - cos - opex) AS net_income,
        sum(CASE WHEN account_number like '4%' or account_number like '80%' then budget_amount
                     when
                      account_number like '5%' or
                      account_number like '6%' or
                      account_number like '7%' or
                      account_number like '85%' THEN budget_amount *-1 END) AS net_income,
        sum(CASE WHEN account_number LIKE '60%' THEN budget_amount END) AS fulfillment,
        sum(CASE WHEN account_number LIKE '61%' THEN budget_amount END) AS product_dev,
        sum(CASE WHEN account_number LIKE '63%' THEN budget_amount END) AS sales_and_marketing,
        sum(CASE WHEN account_number LIKE '70%' THEN budget_amount END) AS labor,
        sum(CASE WHEN account_number LIKE '7%' AND account_number NOT LIKE '70%' THEN budget_amount END) AS g_and_a,
        (revenue - cos) / revenue AS gross_margin,
        (net_income / revenue) AS net_margin,
        budget_version
    FROM
        fact.gl_budget gb
    WHERE
       to_date(posting_period, 'MON YYYY') >='2022-01-01'
    GROUP BY
        posting_period, to_date(posting_period, 'MON YYYY'), budget_version
)
SELECT
    *,
    SUM(revenue) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS revenue_ytd,
    SUM(cogs) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cogs_ytd,
    SUM(inv_adj) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS inv_adj_ytd,
    SUM(royalties) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS royalties_ytd,
    SUM(lcv) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS lcv_ytd,
    SUM(bank_fees) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS bank_fees_ytd,
    SUM(threepl) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS threepl_ytd,
    SUM(amazon_ful) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS amazon_ful_ytd,
    SUM(shipping) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS shipping_ytd,
    SUM(cos) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cos_ytd,
    SUM(opex) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS opex_ytd,
    SUM(net_income) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS net_income_ytd,
    SUM(fulfillment) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS fulfillment_ytd,
    SUM(product_dev) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS product_dev_ytd,
    SUM(sales_and_marketing) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sales_and_marketing_ytd,
    SUM(labor) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS labor_ytd,
    SUM(g_and_a) OVER (PARTITION BY EXTRACT(YEAR FROM posting_period_date), budget_version ORDER BY posting_period_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS g_and_a_ytd,
    (revenue_ytd - cogs_ytd) / revenue_ytd AS gross_margin_ytd,
    (net_income_ytd / revenue_ytd) AS net_margin_ytd,
    quarter(posting_period_date) as quarter,
    date(date_trunc(quarter, posting_period_date)) as quarter_date,
    date_part(year, posting_period_date) as year
FROM (
    SELECT
        *,
       concat(right(posting_period,4), ' - Actual') AS budget_version
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