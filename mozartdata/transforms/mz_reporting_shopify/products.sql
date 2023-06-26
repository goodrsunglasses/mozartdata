-- Step 1. Create a CTE called source and grab all columns from the Shopify source table named "product".

WITH source AS (
  SELECT
    *
  FROM
    shopify.product
),

-- Step 2. Select specific columns from the previous CTE and rename them.

renamed AS (
  SELECT
    _fivetran_deleted AS _fivetran_deleted,
    _fivetran_synced AS _fivetran_synced,
    created_at AS created_timestamp,
    handle AS handle,
    id AS product_id,
    product_type AS product_type,
    published_at AS published_timestamp,
    published_scope AS published_scope,
    title AS title,
    updated_at AS updated_timestamp,
    vendor AS vendor,
  --The below script allows for pass through columns.
    CAST('' AS VARCHAR) AS source_relation
  FROM
    source
),

-- Step 3. Select all columns from the previous CTE.

products AS (
    SELECT
      *
    FROM
      renamed
  ),
  
-- Step 4. Select all columns from the transform table "order_lines"

order_lines AS (
    SELECT
      *
    FROM
      mz_reporting_shopify.order_lines
  ),
  
-- Step 5. Select all tables from the transform table "orders"

orders AS (
    SELECT
      *
    FROM
      mz_reporting_shopify.orders
  ),

-- Step 6. Join the CTEs order_lines and orders using the order_id and source_relation columns. Then, return the total quantity sold, revenue generated from the product, and the timestamps of the first and most recent orders for each product.

order_lines_aggregated AS (
    SELECT
      order_lines.product_id,
      order_lines.source_relation,
      SUM(order_lines.quantity) AS quantity_sold,
      SUM(order_lines.pre_tax_price) AS subtotal_sold,
      MIN(orders.created_timestamp) AS first_order_timestamp,
      MAX(orders.created_timestamp) AS most_recent_order_timestamp
    FROM
      order_lines
      LEFT JOIN orders USING (order_id, source_relation)
    GROUP BY
      1,
      2
  ),
  
-- Step 7. Get data from the CTEs products and order_lines_aggregated. It outputs all columns from the CTE products, the quantity sold, the revenue generated per product, and the first and most recent timestamps the product was sold.

joined AS (
    SELECT
      products.*,
      COALESCE(order_lines_aggregated.quantity_sold, 0) AS quantity_sold,
      COALESCE(order_lines_aggregated.subtotal_sold, 0) AS subtotal_sold,
      order_lines_aggregated.first_order_timestamp,
      order_lines_aggregated.most_recent_order_timestamp
    FROM
      products
      LEFT JOIN order_lines_aggregated USING (product_id, source_relation)
  )
  SELECT
    *
  FROM
    joined