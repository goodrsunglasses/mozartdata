/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per product item.
This transform creates a product list

joins: 
customlist988 joins to item.custitem21 and item.custitem33
customlist991 joins to item.custitem20 and item.custitem30
customlist1271 joins to item.custitem30 and item.custitem29
customlist1272 joins to item.custitem31

aliases: 
i = netsuite.item

*/

SELECT
  i.id as item_id_ns
, i.itemid as sku
, i.incomeaccount
  ,ga.account_display_name
  , ga.account_number
, i.displayname as display_name
, i.itemtype as item_type
, i.custitem5 as collection 
, class.name AS class
, family.name AS family
, stage.name AS stage
, i.fullname as full_name
, i.upccode as upc_code
, i.CUSTITEM18 as lens_sku
, i.vendorname as vendor_name
, i.custitem19 as logo_sku
, i.custitem_psgss_merc_class as merchandise_class
  /* need to figure out the color mapping */
-- , i.custitem_psgss_product_color_desc
-- , i.custitem_psgss_nrf_color_code
, framecolor.name as color_frame
, templecolor.name as color_temple
, framefinish.name as finish_frame
, templefinish.name as finish_temple
, lenscolor.name as color_lens_finish
, i.custitem24 as lens_type
, i.custitem7 as date_d2c_launch --not mapped correctly in mozart
, i.custitem16 as date_b2b_launch
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
FROM
  netsuite.item i
inner join
  draft_dim.gl_account ga
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
  netsuite.CUSTOMLIST_PSGSS_MERC_CLASS class 
  ON i.custitem_psgss_merc_class = class.id
left join 
  netsuite.CUSTOMLIST894 family 
  ON i.custitem4 = family.id
left join 
  netsuite.CUSTOMLIST896 stage 
  ON stage.id = i.custitem6
WHERE
  itemtype in ('InvtPart','Assembly','OthCharge','NonInvtPart','Payment')
and itemtype = 'InvtPart'
/*bring in free shit indicator, merchandise division*/