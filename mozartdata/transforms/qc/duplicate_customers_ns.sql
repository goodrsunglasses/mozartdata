WITH
  cte_count AS (
    SELECT
      COUNT(DISTINCT customer_id_ns) AS distinct_customer_count,
      email
    FROM
      fact.customer_ns_map
    GROUP BY
      email
    HAVING
      COUNT(DISTINCT customer_id_ns) > 1
    ORDER BY
      distinct_customer_count DESC
  )
SELECT
  cte_count.*,
  m.customer_id_ns,
  m.customer_internal_id_ns
from 
  fact.customer_ns_map m
right join cte_count on cte_count.email = m.email