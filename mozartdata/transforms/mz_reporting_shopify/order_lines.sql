-- Step 1. Select all columns from the product_variant table from the source schema.

WITH source AS (
  SELECT
    *
  FROM
    shopify.product_variant
),

-- Step 2. Select a set of columns from the previous CTE (source) and assign new names to them.

renamed_product AS (
  SELECT
    id AS variant_id,
    _fivetran_synced AS _fivetran_synced,
    created_at AS created_timestamp,
    updated_at AS updated_timestamp,
    product_id AS product_id,
    inventory_item_id AS inventory_item_id,
    image_id AS image_id,
    title AS title,
    price AS price,
    sku AS sku,
    POSITION AS POSITION,
    inventory_policy AS inventory_policy,
    compare_at_price AS compare_at_price,
    fulfillment_service AS fulfillment_service,
    inventory_management AS inventory_management,
    taxable AS is_taxable,
    barcode AS barcode,
    grams AS grams,
    inventory_quantity AS inventory_quantity,
    weight AS weight,
    weight_unit AS weight_unit,
    option_1 AS option_1,
    option_2 AS option_2,
    option_3 AS option_3,
    tax_code AS tax_code,
    old_inventory_quantity AS old_inventory_quantity,
    requires_shipping AS is_requiring_shipping,
--The below script allows for pass through columns.
    CAST('' AS VARCHAR) AS source_relation
  FROM
    source
),

-- Step 3. Define another CTE called "renamed_order" and select specific columns from the order_line table in the source schema table, and assign new names to them.

renamed_order AS (
    SELECT
      _fivetran_synced AS _fivetran_synced,
      fulfillable_quantity AS fulfillable_quantity,
      ---fulfillment_service AS fulfillment_service, --- gd commented out because it was breaking the transform
      fulfillment_status AS fulfillment_status,
      gift_card AS is_gift_card,
      grams AS grams,
      id AS order_line_id,
      index AS index,
      name AS name,
      order_id AS order_id,
      pre_tax_price AS pre_tax_price,
      price AS price,
      product_id AS product_id,
      CAST(NULL AS NUMERIC(28, 6)) AS property_charge_interval_frequency,
      CAST(NULL AS VARCHAR) AS property_for_shipping_jan_3_rd_2020,
      CAST(NULL AS NUMERIC(28, 6)) AS property_shipping_interval_frequency,
      CAST(NULL AS VARCHAR) AS property_shipping_interval_unit_type,
      CAST(NULL AS NUMERIC(28, 6)) AS property_subscription_id,
      quantity AS quantity,
      requires_shipping AS is_requiring_shipping,
      sku AS sku,
      taxable AS is_taxable,
      title AS title,
      total_discount AS total_discount,
      variant_id AS variant_id,
      vendor AS vendor,
  --The below script allows for pass through columns.
      CAST('' AS VARCHAR) AS source_relation
    FROM
      shopify.order_line
  ),

-- Step 4. Define a new CTE called "order_lines" and select all columns from the CTE renamed_order.

order_lines AS (
  SELECT
    *
  FROM
    renamed_order
),

-- Step 5. Define a new CTE called "product_variants" and select all columns from the CTE renamed_product.

product_variants AS (
  SELECT
    *
  FROM
    renamed_product
),

-- Step 6. Combine the data from the CTEs order_lines and product_variants by joining on the variant_id column and source_relation.
joined AS (
  SELECT
    order_lines.*,
    product_variants.created_timestamp AS variant_created_at,
    product_variants.updated_timestamp AS variant_updated_at,
    product_variants.inventory_item_id,
    product_variants.image_id,
    product_variants.title AS variant_title,
    product_variants.price AS variant_price,
    product_variants.sku AS variant_sku,
    product_variants.position AS variant_position,
    product_variants.inventory_policy AS variant_inventory_policy,
    product_variants.compare_at_price AS variant_compare_at_price,
    product_variants.fulfillment_service AS variant_fulfillment_service,
    product_variants.inventory_management AS variant_inventory_management,
    product_variants.is_taxable AS variant_is_taxable,
    product_variants.barcode AS variant_barcode,
    product_variants.grams AS variant_grams,
    product_variants.inventory_quantity AS variant_inventory_quantity,
    product_variants.weight AS variant_weight,
    product_variants.weight_unit AS variant_weight_unit,
    product_variants.option_1 AS variant_option_1,
    product_variants.option_2 AS variant_option_2,
    product_variants.option_3 AS variant_option_3,
    product_variants.tax_code AS variant_tax_code,
    product_variants.is_requiring_shipping AS variant_is_requiring_shipping
  FROM
    order_lines
    LEFT JOIN product_variants ON product_variants.variant_id = order_lines.variant_id
    AND product_variants.source_relation = order_lines.source_relation
)

-- Step 7. Select all columns and results from the CTE joined.

SELECT
  *
FROM
  joined