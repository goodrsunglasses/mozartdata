SELECT *, LOWER(split(vendor_name,' ')[0]) as location,LOWER(split(vendor_name,' ')[1]) as vendor,
  datediff('day',purchase_date,fulfillment_date) fulfillment_time 
  
  FROM fact.purchase_orders
where purchase_date != fulfillment_date and (order_id_edw like '%ATL%' or order_id_edw like '%LAG%' or order_id_edw like '%LAS%')