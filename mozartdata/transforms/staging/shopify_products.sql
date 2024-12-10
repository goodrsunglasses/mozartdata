/*
Purpose: The entire point of this table is to comfortably union all shopify product information onto one table, as its split between 5 connectors
One row per product id (variant_id) per store.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
SELECT
    FIRST_VALUE(variant.PRODUCT_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at
    )         AS product_id
  , prod.title
  , prod.product_type
  , variant.id    AS variant_id
  , prod.status
  , FIRST_VALUE(variant.INVENTORY_ITEM_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at asc
    )             AS inventory_item_id
  , variant.title AS variant_title
  , variant.price
  , variant.compare_at_price
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'Goodr.com'         AS shopify_store
FROM
    shopify.PRODUCT_VARIANT variant
    LEFT OUTER JOIN
        shopify.PRODUCT     prod
            ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT
    FIRST_VALUE(variant.PRODUCT_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at
    )         AS product_id
  , prod.title
  , prod.product_type
  , variant.id    AS variant_id
  , prod.status
  , FIRST_VALUE(variant.INVENTORY_ITEM_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at asc
    )             AS inventory_item_id
  , variant.title AS variant_title
  , variant.price
  , variant.compare_at_price
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'Specialty'         AS shopify_store
FROM
    SPECIALTY_SHOPIFY.PRODUCT_VARIANT         variant
    LEFT OUTER JOIN SPECIALTY_SHOPIFY.PRODUCT prod
        ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT
    FIRST_VALUE(variant.PRODUCT_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at
    )         AS product_id
  , prod.title
  , prod.product_type
  , variant.id    AS variant_id
  , prod.status
  , FIRST_VALUE(variant.INVENTORY_ITEM_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at asc
    )             AS inventory_item_id
  , variant.title AS variant_title
  , variant.price
  , variant.compare_at_price
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'Goodrwill'         AS shopify_store
FROM
    GOODRWILL_SHOPIFY.PRODUCT_VARIANT         variant
    LEFT OUTER JOIN GOODRWILL_SHOPIFY.PRODUCT prod
        ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT
    FIRST_VALUE(variant.PRODUCT_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at
    )         AS product_id
  , prod.title
  , prod.product_type
  , variant.id    AS variant_id
  , prod.status
  , FIRST_VALUE(variant.INVENTORY_ITEM_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at asc
    )             AS inventory_item_id
  , variant.title AS variant_title
  , variant.price
  , variant.compare_at_price
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'Specialty CAN'         AS shopify_store
FROM
    SELLGOODR_CANADA_SHOPIFY.PRODUCT_VARIANT         variant
    LEFT OUTER JOIN SELLGOODR_CANADA_SHOPIFY.PRODUCT prod
        ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT
    FIRST_VALUE(variant.PRODUCT_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at
    )         AS product_id
  , prod.title
  , prod.product_type
  , variant.id    AS variant_id
  , prod.status
  , FIRST_VALUE(variant.INVENTORY_ITEM_ID) OVER (
        PARTITION BY
            variant.sku
        ORDER BY
            variant.created_at asc
    )             AS inventory_item_id
  , variant.title AS variant_title
  , variant.price
  , variant.compare_at_price
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'Goodr.ca'         AS shopify_store
FROM
    GOODR_CANADA_SHOPIFY.PRODUCT_VARIANT         variant
    LEFT OUTER JOIN GOODR_CANADA_SHOPIFY.PRODUCT prod
        ON prod.id = variant.PRODUCT_ID