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
  item.id,
  fullname,
  item.displayname,
  item.externalid,
  item_cust_fields.class,
  family,
  stage
FROM
  netsuite.item item
  LEFT OUTER JOIN item_cust_fields ON item.id = item_cust_fields.id
-- WHERE
--   item.id = 23