SELECT p.stage,
  p.item_id_ns,
  p.collection,
  display_name,
  p.product_id_edw,
  p.color_lens_base,
  p.color_lens_finish,
  p.lens_type,
  p.lens_tech
FROM fact.order_item_detail oid
  left join dim.product p on p.product_id_edw = oid.product_id_edw
WHERE distributor_portal_item_flag = 'true' 
  and oid.product_id_edw IS NOT NULL 
  and p.stage IN ('ACTIVE','NOT RELEASED','UPCOMING') 
  and p.color_lens_finish IS NOT NULL
GROUP BY display_name, 
  p.stage, 
  p.item_id_ns, 
  p.collection, 
  p.product_id_edw, 
  p.color_lens_finish, 
  p.color_lens_base, 
  p.lens_type, 
  p.lens_tech
ORDER by p.stage