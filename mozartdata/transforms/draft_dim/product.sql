WITH
  assembly_aggregate AS (
    SELECT
      parentitem,
      SUM(quantity) AS assembly_quantity
    FROM
      netsuite.itemmember
    GROUP BY
      parentitem
    HAVING
      assembly_quantity IS NOT NULL
  )
SELECT
  i.id AS product_id_edw,
  i.id AS item_id_ns,
  d2c.id as d2c_id_shopify,
  b2b.id as b2b_id_shopify,
  i.itemid AS sku,
  i.displayname AS display_name,
  i.itemtype AS item_type,
  i.custitem5 AS collection,
  family.name AS family,
  stage.name AS stage,
  i.fullname AS full_name,
  class.name AS merchandise_class,
  dept.name AS merchandise_department,
  division.name AS merchandise_division,
  i.upccode AS upc_code,
  i.CUSTITEM18 AS lens_sku,
  i.vendorname AS vendor_name,
  i.custitem19 AS logo_sku,
  framecolor.name AS color_frame,
  templecolor.name AS color_temple,
  framefinish.name AS finish_frame,
  templefinish.name AS finish_temple,
  lenscolor.name AS color_lens_finish,
  i.custitem24 AS lens_type,
  i.custitem7 AS d2c_launch_timestamp,
  DATE(i.custitem7) AS d2c_launch_date,
  i.custitem16 AS b2b_launch_timestamp,
  DATE(i.custitem16) AS b2b_launch_date,
  i.custitem_goodr_mc_ip_qty AS mc_quantity,
  i.custitem_goodr_mc_weight AS mc_weight_oz,
  i.custitem_goodr_mc_length AS mc_length_in,
  i.custitem_goodr_mc_width AS mc_width_in,
  i.custitem_goodr_item_height AS mc_height_in,
  i.custitem3 AS ip_weight_oz,
  i.custitem_goodr_ip_length AS ip_length_in,
  i.custitem_good_ip_width AS ip_width_in,
  i.custitem_goodr_ip_height AS ip_height_in,
  i.custitem_goodr_hts_code_item AS hts_code,
  i.CUSTITEM1 AS country_of_origin,
  CASE
    WHEN i.custitemmozard_gp_flag = 'T' THEN TRUE
    ELSE FALSE
  END free_shit_flag,
  assembly_quantity,
  CAST(
    CASE
      WHEN LEFT(i.itemid, 2) = 'GC' THEN SPLIT_PART(i.itemid, '-', 2)
    END AS int
  ) gift_card_amount,
  i.incomeaccount AS account_id_ns,
  ga.account_number,
  ga.account_display_name
FROM
  netsuite.item i
  INNER JOIN dim.gl_account ga ON i.incomeaccount = ga.account_id_ns
  LEFT JOIN netsuite.customlist991 framecolor ON i.custitem20 = framecolor.id
  LEFT JOIN netsuite.customlist991 templecolor ON i.custitem32 = templecolor.id
  LEFT JOIN netsuite.customlist988 framefinish ON i.custitem21 = framefinish.id
  LEFT JOIN netsuite.customlist988 templefinish ON i.custitem33 = templefinish.id
  LEFT JOIN netsuite.customlist_psgss_product_color lenscolor ON i.custitem22 = lenscolor.id
  LEFT JOIN netsuite.customlist_psgss_product_color lenscolorbase ON i.custitem28 = lenscolorbase.id
  LEFT JOIN netsuite.customlist_psgss_merc_class class ON i.custitem_psgss_merc_class = class.id
  LEFT JOIN netsuite.customlist_psgss_merc_dept dept ON i.custitem_psgss_merc_dept = dept.id
  LEFT JOIN netsuite.customlist_psgss_merc_division division ON i.custitem_psgss_merc_division = division.id
  LEFT JOIN netsuite.customlist894 family ON i.custitem4 = family.id
  LEFT JOIN netsuite.customlist896 stage ON i.custitem6 = stage.id
  LEFT JOIN assembly_aggregate agg ON i.id = agg.parentitem
  left join shopify.product_variant d2c on d2c.sku=i.itemid
  left join specialty_shopify.product_variant b2b on b2b.sku=i.itemid
WHERE
  itemtype IN (
    'InvtPart',
    'Assembly',
    'OthCharge',
    'NonInvtPart',
    'Payment'
  )