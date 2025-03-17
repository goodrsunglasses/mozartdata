SELECT p.stage, p.item_id_ns, p.collection, display_name, p.product_id_edw, p.color_lens_finish
FROM fact.order_item_detail oid
  left join dim.product p on p.product_id_edw = oid.product_id_edw
WHERE channel = 'Global' and oid.product_id_edw IS NOT NULL and p.stage IN ('ACTIVE','NOT RELEASED','UPCOMING') AND p.color_lens_finish IS NOT NULL
GROUP BY display_name, p.stage, p.item_id_ns, p.collection, p.product_id_edw, p.color_lens_finish
ORDER by p.stage