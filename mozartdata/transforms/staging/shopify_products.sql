--The entire point of this table is to comfortably union all shopify product information onto one table, as its split between 5 connectors
SELECT PRODUCT_ID,
	   prod.title,
	   product_type,
	   variant.id    AS variant_id,
	   status,
	   INVENTORY_ITEM_ID,
	   variant.title AS variant_title,
	   price,
	   sku,
	   barcode,
	   grams,
	   weight,
	   weight_unit,
	   option_1
FROM shopify.PRODUCT_VARIANT variant
		 LEFT OUTER JOIN shopify.PRODUCT prod ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT 
           variant.PRODUCT_ID,
	   prod.title,
	   prod.product_type,
	   variant.id    AS variant_id,
	   prod.status,
	   variant.INVENTORY_ITEM_ID,
	   variant.title AS variant_title,
	   variant.price,
	   variant.sku,
	   variant.barcode,
	   variant.grams,
	   variant.weight,
	   variant.weight_unit,
	   variant.option_1
FROM SPECIALTY_SHOPIFY.PRODUCT_VARIANT variant
		 LEFT OUTER JOIN SPECIALTY_SHOPIFY.PRODUCT prod ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT 
           variant.PRODUCT_ID,
	   prod.title,
	   prod.product_type,
	   variant.id    AS variant_id,
	   prod.status,
	   variant.INVENTORY_ITEM_ID,
	   variant.title AS variant_title,
	   variant.price,
	   variant.sku,
	   variant.barcode,
	   variant.grams,
	   variant.weight,
	   variant.weight_unit,
	   variant.option_1
FROM GOODRWILL_SHOPIFY.PRODUCT_VARIANT variant
		 LEFT OUTER JOIN GOODRWILL_SHOPIFY.PRODUCT prod ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT 
           variant.PRODUCT_ID,
	   prod.title,
	   prod.product_type,
	   variant.id    AS variant_id,
	   prod.status,
	   variant.INVENTORY_ITEM_ID,
	   variant.title AS variant_title,
	   variant.price,
	   variant.sku,
	   variant.barcode,
	   variant.grams,
	   variant.weight,
	   variant.weight_unit,
	   variant.option_1
FROM SELLGOODR_CANADA_SHOPIFY.PRODUCT_VARIANT variant
		 LEFT OUTER JOIN SELLGOODR_CANADA_SHOPIFY.PRODUCT prod ON prod.id = variant.PRODUCT_ID
UNION ALL
SELECT 
           variant.PRODUCT_ID,
	   prod.title,
	   prod.product_type,
	   variant.id    AS variant_id,
	   prod.status,
	   variant.INVENTORY_ITEM_ID,
	   variant.title AS variant_title,
	   variant.price,
	   variant.sku,
	   variant.barcode,
	   variant.grams,
	   variant.weight,
	   variant.weight_unit,
	   variant.option_1
FROM GOODR_CANADA_SHOPIFY.PRODUCT_VARIANT variant
		 LEFT OUTER JOIN GOODR_CANADA_SHOPIFY.PRODUCT prod ON prod.id = variant.PRODUCT_ID
