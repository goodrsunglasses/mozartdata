WITH
  --CTE to select all the Goodr.com Shopify customer records and assign them D2C for obv reasons
  d2c_shop AS (
    SELECT
      id,
      email,
      first_name || ' ' || last_name AS fullname,
      'D2C' AS category
    FROM
      shopify.customer shop_cust
  ),
  --CTE to select all the sellgoodr.com Shopify customer records and assign them B2B for obv reasons
  b2b_shop AS (
    SELECT
      id,
      email,
      first_name || ' ' || last_name AS fullname,
      'B2B' AS category
    FROM
      specialty_shopify.customer shop_cust
  )
SELECT
  customer_id_edw,
  COALESCE(d2c_shop.id, b2b_shop.id) AS customer_id_shopify,
  coalesce(d2c_shop.fullname,b2b_shop.fullname) as full_name,
  dim_cust.email,
  customer_category
FROM
  --double joins since we know which category each shopify ID is due to it being from either Goodr.com or SG
  dim.customer dim_cust
  LEFT OUTER JOIN d2c_shop ON (
    dim_cust.email = d2c_shop.email
    AND d2c_shop.category = dim_cust.customer_category
  )
  LEFT OUTER JOIN b2b_shop ON (
    dim_cust.email = b2b_shop.email
    AND b2b_shop.category = dim_cust.customer_category
  )
WHERE
  --Ignoring Indirect customers, as well as the customers who are D2C/B2B but not in one of our two shopify stores.
  customer_category != 'INDIRECT'
  AND customer_id_shopify IS NOT NULL