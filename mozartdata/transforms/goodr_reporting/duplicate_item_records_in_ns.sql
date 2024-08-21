with cte as (
  SELECT
  display_name,
  COUNT(*) AS duplicate_count
FROM
  dim.product
WHERE
  sku NOT ILIKE '%htb'
  AND item_id_ns IS NOT NULL
GROUP BY
  display_name
HAVING
  COUNT(*) > 1

)

SELECT
  cte.display_name,
  p.sku,
  p.item_id_ns,
  p.merchandise_class
FROM
 cte
left join dim.product p on p.display_name = cte.display_name
order by display_name