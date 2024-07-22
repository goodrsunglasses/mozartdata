WITH
  pgashow24_custs AS (
    SELECT
      *
    FROM
      specialty_shopify.customer_tag
    WHERE
      value = 'pgashow'
      AND _fivetran_synced >= '2024-01-23T00:00:00'
  )
SELECT
  o.*,
  nsc.customer_name,
  nsc.customer_number,
  date_part(month, sold_date) as sold_month,
  date_part(year, sold_date) as sold_year
FROM
  fact.orders o
  LEFT JOIN fact.customer_shopify_map c ON o.customer_id_edw = c.customer_id_edw
  INNER JOIN pgashow24_custs pga ON c.id = pga.customer_id
  left join fact.customer_ns_map nsc on o.customer_id_ns = nsc.customer_id_ns