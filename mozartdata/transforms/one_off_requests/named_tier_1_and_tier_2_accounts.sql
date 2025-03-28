WITH
  customers AS (
    SELECT
      *,
      coalesce(parent_id_ns, customer_id_ns) AS parent_grouping
    FROM
      fact.customer_ns_map
  ),
  totals AS (
    SELECT
      parent_grouping,
      map.customer_id_ns,
      map.customer_number,
      map.entity_title,
      channel,
      map.tier,
      map.doors,
      date_trunc(month, transaction_date),
      sum(net_amount) as revenue
    FROM
      fact.gl_transaction t
      INNER JOIN customers c ON c.customer_id_edw = t.customer_id_edw
      inner join fact.customer_ns_map map on map.customer_id_ns = c.parent_grouping
    WHERE
      posting_flag
      AND account_number LIKE '4%'
      AND transaction_date BETWEEN '2024-01-01' AND '2024-12-31'
      AND channel IN ('Key Accounts', 'Specialty', 'Key Account CAN', 'Specialty CAN', 'Global')
      AND map.tier IN('Named', '1A', '1B', '1C', '1O', '2A', '2B', '2C', '2O')
    GROUP BY
      all
  )
  -----
SELECT
--  sum(total)
   *
FROM
  totals
ORDER BY
  revenue desc