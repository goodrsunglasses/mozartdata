SELECT
  count(DISTINCT so.customer_id) AS shopify_customer_count,
  year(so.created_at) year_of_first_order,
  sum(
    CASE
      WHEN nsmap.doors IS NULL THEN 1
      ELSE nsmap.doors
    END
  ) AS door_count,
  tier
FROM
  specialty_shopify."ORDER" so
  LEFT JOIN fact.customer_shopify_map smap ON so.customer_id = smap.id
  LEFT JOIN fact.customer_ns_map nsmap ON smap.customer_id_edw = nsmap.customer_id_edw
GROUP BY
  year(so.created_at),
  tier