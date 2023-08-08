WITH
  item_cust_fields AS (
    SELECT
      item.id,
      class.name AS class,
      family.name AS family,
      stage.name AS stage
    FROM
      netsuite.item item
      LEFT OUTER JOIN netsuite.CUSTOMLIST_PSGSS_MERC_CLASS class ON item.custitem_psgss_merc_class = class.id
      LEFT OUTER JOIN netsuite.CUSTOMLIST894 family ON item.custitem4 = family.id
      LEFT OUTER JOIN netsuite.CUSTOMLIST896 stage ON stage.id = item.custitem6
  )
SELECT
  item.id as ns_item_id,
  item.displayname,
  item.externalid as sku,
  item_cust_fields.class,
  family,
  stage,
  item.custitem5 as collection,
  item.custitem18 as lens_sku,
  item.upccode,
  item.totalquantityonhand,
  item.averagecost,
  item.cost
FROM
  netsuite.item item
  LEFT OUTER JOIN item_cust_fields ON item.id = item_cust_fields.id