-- Step 1. Select columns from the source table order_line and assign new names to some of them. Also include several columns that are set to NULL and one column that is set to an empty string; these columns will be used later.

WITH renamed AS (
  SELECT
    _fivetran_synced AS _fivetran_synced,
    fulfillable_quantity AS fulfillable_quantity,
    fulfillment_service AS fulfillment_service,
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
    specialty_shopify.order_line
),

-- Step 2. Aggregate data from the previous CTE by grouping by the columns order_id and source_relation, and calculating the count of rows in each group.

aggregated AS (
  SELECT
    order_id,
    source_relation,
    COUNT(*) AS line_item_count
  FROM
    renamed
  GROUP BY
    1,
    2
)

-- Step 3. Select all columns from the previous CTE.

SELECT
  *
FROM
  aggregated