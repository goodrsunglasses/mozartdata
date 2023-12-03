WITH assembly_aggregate AS(
  SELECT 
    parentitem
   ,SUM(quantity) as assembly_quantity
  FROM 
    netsuite.itemmember
  GROUP BY 
    parentitem
  HAVING
    assembly_quantity is not null
)
SELECT
  i.id as product_id_edw
, i.id as item_id_ns
, i.itemid as sku
, i.displayname as display_name
, i.itemtype as item_type
, i.custitem5 as collection 
, family.name as family
, stage.name as stage
, i.fullname as full_name
, class.name as merchandise_class
, dept.name as merchandise_department
, division.name as merchandise_division
, i.upccode as upc_code
, i.CUSTITEM18 as lens_sku
, i.vendorname as vendor_name
, i.custitem19 as logo_sku
, framecolor.name as color_frame
, templecolor.name as color_temple
, framefinish.name as finish_frame
, templefinish.name as finish_temple
, lenscolor.name as color_lens_finish
, i.custitem24 as lens_type
, i.custitem7 as d2c_launch_timestamp 
, date(i.custitem7) as d2c_launch_date  
, i.custitem16 as b2b_launch_timestamp
, date(i.custitem16) as b2b_launch_date
, i.custitem_goodr_mc_ip_qty as mc_quantity
, i.custitem_goodr_mc_weight as mc_weight_oz
, i.custitem_goodr_mc_length as mc_length_in
, i.custitem_goodr_mc_width as mc_width_in
, i.custitem_goodr_item_height as mc_height_in
, i.custitem3 as ip_weight_oz
, i.custitem_goodr_ip_length as ip_length_in
, i.custitem_good_ip_width as ip_width_in
, i.custitem_goodr_ip_height as ip_height_in
, i.custitem_goodr_hts_code_item as hts_code
, i.CUSTITEM1 as country_of_origin
, case when i.custitemmozard_gp_flag = 'T' then true else false end free_shit_flag
, assembly_quantity
, cast(case when left(i.itemid,2) = 'GC' then SPLIT_PART(i.itemid, '-', 2) end as int) gift_card_amount
, i.incomeaccount as account_id_ns
, ga.account_number
, ga.account_display_name
FROM
  netsuite.item i
inner join
  dim.gl_account ga
  on i.incomeaccount = ga.account_id_ns
left join
  netsuite.customlist991 framecolor
  on i.custitem20 = framecolor.id
left join
  netsuite.customlist991 templecolor
  on i.custitem32 = templecolor.id
left join
  netsuite.customlist988 framefinish
  on i.custitem21 = framefinish.id
left join
  netsuite.customlist988 templefinish
  on i.custitem33 = templefinish.id
left join
  netsuite.customlist_psgss_product_color lenscolor
  on i.custitem22 = lenscolor.id
left join
  netsuite.customlist_psgss_product_color lenscolorbase
  on i.custitem28 = lenscolorbase.id
left join 
  netsuite.customlist_psgss_merc_class class 
  ON i.custitem_psgss_merc_class = class.id
left join
  netsuite.customlist_psgss_merc_dept dept
  on i.custitem_psgss_merc_dept = dept.id
left join
  netsuite.customlist_psgss_merc_division division
  on i.custitem_psgss_merc_division = division.id
left join 
  netsuite.customlist894 family 
  ON i.custitem4 = family.id
left join 
  netsuite.customlist896 stage 
  ON i.custitem6 = stage.id
left join 
  assembly_aggregate agg 
  ON i.id = agg.parentitem
WHERE
  itemtype in ('InvtPart','Assembly','OthCharge','NonInvtPart','Payment')