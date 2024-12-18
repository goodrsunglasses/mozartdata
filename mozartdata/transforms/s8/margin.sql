SELECT
      t.product_id_edw,
      t.channel,
      t.posting_period,
      SUM(coalesce(-tranline.quantity,0)) quantity,
      sum(-tranline.costestimate) as cost_est,
      sum(t.net_amount) AS revenue,
      div0(sum(t.net_amount) , SUM(coalesce(-tranline.quantity,0))) as unit_rev,
      div0(sum(-tranline.costestimate) , SUM(coalesce(-tranline.quantity,0))) as unit_cost 
    FROM
      fact.gl_transaction t
      LEFT JOIN
        netsuite.transactionline tranline
        ON tranline.transaction = t.transaction_id_ns
        AND tranline.id = t.transaction_line_id_ns
        AND tranline.item = t.item_id_ns
        AND tranline.mainline = 'F'
        AND tranline.accountinglinetype = 'INCOME'
        AND (tranline._FIVETRAN_DELETED = false or tranline._FIVETRAN_DELETED is null)
    WHERE
      posting_flag
      AND account_number LIKE '4%'
    GROUP BY all

  /*
  cost AS (
    SELECT
      product_id_edw,
      channel,
      posting_period,
      sum(net_amount) AS cost
    FROM
      fact.gl_transaction
    WHERE
      posting_flag
      AND account_number LIKE '5%'   --- add in the old cost of sales accounts
    GROUP BY
      ALL
  ),
  core AS (
  SELECT
      r.product_id_edw,
      r.channel,
      r.posting_period,
      p.merchandise_department,
      p.family AS product_category,
      p.merchandise_class AS model,
      r.revenue,
      c.cost
    FROM
      revenue r
      LEFT JOIN cost c using (product_id_edw, channel, posting_period)
      LEFT JOIN dim.product p ON r.product_id_edw = p.product_id_edw
  )
SELECT
  *
FROM
  core
*/