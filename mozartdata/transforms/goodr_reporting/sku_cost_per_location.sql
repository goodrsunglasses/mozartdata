SELECT
  il.item as item_id_ns,
  p.display_name,
  il.lastpurchasepricemli as average_cost,
  l.full_name as location,
  date(il._fivetran_synced) as date,
FROM
  netsuite.inventoryitemlocations il
  LEFT JOIN dim.location l ON l.location_id_ns = il.location
  left join dim.product p on il.item = p.item_id_ns
where average_cost is not null