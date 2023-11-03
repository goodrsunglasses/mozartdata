SELECT 
  p.item_id_ns,
  p.display_name,
  min(p.d2c_launch_date) as earlist_d2c_launch_date,
  min(oid.transaction_date_pst) as earliest_sale
FROM draft_dim.product p
LEFT JOIN fact.order_item_detail oid ON p.item_id_ns = oid.item_id_ns
GROUP BY p.item_id_ns, p.display_name;