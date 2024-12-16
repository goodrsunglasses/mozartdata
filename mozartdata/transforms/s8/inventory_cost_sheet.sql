WITH RecentPrices AS (
  SELECT
    il.item,
    il.location,
    MAX(il._fivetran_synced) AS max_synced
  FROM
    netsuite.inventoryitemlocations il
  GROUP BY
    il.item,
    il.location
),
ItemAvgCost AS (
  SELECT
    item,
    AVG(NULLIF(il.lastpurchasepricemli, 0)) AS avg_non_zero_cost
  FROM
    netsuite.inventoryitemlocations il
  WHERE
    il.lastpurchasepricemli IS NOT NULL AND il.lastpurchasepricemli != 0
  GROUP BY
    item
)
SELECT
  il.item AS item_id_ns,
  p.display_name,
  p.sku,
  p.family as category,
  p.merchandise_class as model,
  il.lastpurchasepricemli AS average_cost,
  COALESCE(
    CASE 
      WHEN il.lastpurchasepricemli = 0 OR il.lastpurchasepricemli IS NULL 
      THEN iac.avg_non_zero_cost
      ELSE il.lastpurchasepricemli 
    END, 
    0
  ) AS average_cost_upd,
  l.full_name AS location,
  l.location_id_ns,
  DATE(rp.max_synced) AS date_as_of
FROM
  netsuite.inventoryitemlocations il
  LEFT JOIN dim.location l ON l.location_id_ns = il.location
  INNER JOIN RecentPrices rp ON il.item = rp.item
    AND il.location = rp.location
    AND il._fivetran_synced = rp.max_synced
  LEFT JOIN ItemAvgCost iac ON il.item = iac.item
  LEFT JOIN dim.product p ON il.item = p.item_id_ns
WHERE 
   p.merchandise_department = 'SUNGLASSES'