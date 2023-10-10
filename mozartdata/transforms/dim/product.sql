/*
THIS TRANSFORM IS IN DRAFT, DO NOT JOIN TO THIS TRANSFORM OR USE IT FOR ANY REPORTING UNTIL IT IS CERTIFIED.
purpose:
One row per product item.
This transform creates a product list

joins: 
self joins to account to pull the parent account number

aliases: 
i = netsuite.item

*/

SELECT
  i.id as item_id_ns
, i.itemid as sku
, i.displayname as display_name
, i.custitem5 as collection 
, i.fullname as full_name
, i.upccode as upc_code
, i.CUSTITEM18 as lens_sku
, i.vendorname as vendor_name
, i.custitem19 as logo_sku
, i.custitem_psgss_merc_class as merchandise_class
  /* need to figure out the color mapping */
, i.custitem_psgss_product_color_desc
, i.custitem_psgss_nrf_color_code
,  i.custitem20 as color_frame_id
, framecolor.name as color_frame
, i.custitem28 as color_lens_base_id --missing in mozart
, lenscolorbase.name as color_lens_base
, i.custitem22 as color_lens_finish_id
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
left join
  netsuite.customlist_psgss_product_color framecolor
  on i.custitem20 = framecolor.id
left join
  netsuite.customlist_psgss_product_color lenscolor
  on i.custitem22 = lenscolor.id
left join
  netsuite.customlist_psgss_product_color lenscolorbase
  on i.custitem28 = lenscolorbase.id
WHERE
  itemtype = 'InvtPart'