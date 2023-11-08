SELECT
  *
FROM
  fact.orders
WHERE
  model = 'Distribution'
  and order_date_pst >= '2023-01-01'

SELECT
DISTINCT o.customer_id_edw,
from fact.orders o
  join draft_fact.customer c on 
where 
  model = 'Distribution'
  and order_date_pst >= '2023-01-01'