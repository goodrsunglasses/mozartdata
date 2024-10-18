SELECT
  count(DISTINCT so.customer_id) as shopify_customer_count,
  year(so.created_at) year_of_first_order,
--  so.shipping_address_zip,
--  so.shipping_address_province_code,
  sum(nsmap.doors) as door_count,
  tier
FROM
  specialty_shopify."ORDER" so
  left join fact.customer_shopify_map smap on so.customer_id = smap.id
  left join fact.customer_ns_map nsmap on smap.customer_id_edw = nsmap.customer_id_edw
--WHERE nsmap.tier like '1%'
GROUP BY
  year(so.created_at), tier