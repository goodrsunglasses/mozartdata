WITH
  customers AS (
    SELECT
      *,
      COALESCE(parent_id_ns, customer_id_ns) AS parent_grouping
    FROM
      fact.customer_ns_map
  ),
  totals AS (
    SELECT
      DATE_TRUNC('month', t.transaction_date) AS transaction_month,
      c.parent_grouping,
      map.customer_id_ns,
      map.customer_number,
      map.entity_title,
      map.tier,
      map.doors,
      SUM(t.net_amount) AS revenue
    FROM
      fact.gl_transaction t
      INNER JOIN customers c ON c.customer_id_edw = t.customer_id_edw
      INNER JOIN fact.customer_ns_map map ON map.customer_id_ns = c.parent_grouping
    WHERE
      t.posting_flag
      AND t.account_number LIKE '4%'
      AND t.transaction_date > '2024-12-31'
      AND t.channel = 'Specialty'
      AND map.tier IN ('3A', '3B', '3C', '3O')
    GROUP BY
      transaction_month, 
      c.parent_grouping,
      map.customer_id_ns,
      map.customer_number,
      map.entity_title,
      map.tier,
      map.tier_2024,
      map.doors
  )
SELECT
  *
FROM
  totals
WHERE
  revenue > 10000
ORDER BY
  transaction_month DESC, revenue DESC;