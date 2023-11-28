SELECT 
  poi.*,
  po.vendor_name,
  po.purchase_date
FROM fact.purchase_order_item poi
join fact.purchase_orders po on poi.order_id_edw = po.order_id_edw