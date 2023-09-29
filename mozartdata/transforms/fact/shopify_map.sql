WITH
  d2c_shop AS (
    SELECT
      id,
      email,
      'D2C' AS category
    FROM
      shopify.customer shop_cust
  ),
  b2b_shop AS (
    SELECT
      id,
      email,
      'B2B' AS category
    FROM
      specialty_shopify.customer shop_cust
  )
SELECT
  customer_id_edw,
  COALESCE(d2c_shop.id, b2b_shop.id) AS shopify_id,
  customer_category
FROM
  draft_dim.customers dim_cust
  LEFT OUTER JOIN d2c_shop ON (
    dim_cust.email = d2c_shop.email
    AND d2c_shop.category = dim_cust.customer_category
  )
  LEFT OUTER JOIN b2b_shop ON (
    dim_cust.email = b2b_shop.email
    AND b2b_shop.category = dim_cust.customer_category
  )
WHERE
  customer_category != 'INDIRECT'