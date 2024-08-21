SELECT
  *
FROM
  dim.product
WHERE
  sku NOT ILIKE '%htb'
  AND item_id_ns IS NOT NULL
---- still the issue of multiple ids in NS