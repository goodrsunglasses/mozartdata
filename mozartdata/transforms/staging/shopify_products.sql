--The entire point of this table is to comfortably union all shopify product information onto one table, as its split between 5 connectors
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
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'd2c'         AS shopify_store
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
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'b2b'         AS shopify_store
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
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'goodrwill'         AS shopify_store
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
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'b2b_can'         AS shopify_store
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
  , variant.sku
  , variant.barcode
  , variant.grams
  , variant.weight
  , variant.weight_unit
  , variant.option_1
  , 'd2c_can'         AS shopify_store
FROM
    GOODR_CANADA_SHOPIFY.PRODUCT_VARIANT         variant
    LEFT OUTER JOIN GOODR_CANADA_SHOPIFY.PRODUCT prod
        ON prod.id = variant.PRODUCT_ID
