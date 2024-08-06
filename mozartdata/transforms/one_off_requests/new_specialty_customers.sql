SELECT fc.* 
FROM archive.customer fc
join dim.customer dc on fc.customer_id_edw = dc.customer_id_edw
WHERE 
  first_order_date > '2023-09-01'
  and dc.customer_category = 'B2B'