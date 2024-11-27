/*
Purpose: show Stord inventory reservations.
One row per reservation, which breaks down to one row per sku per store per snapshot.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
                  )
  , parsed_json as
  (
    SELECT
      sni.*
    ,  parse_json(sni.network_balances) as network_balances_parsed
    FROM
      stord.stord_network_inventory_8589936822 sni
  )
SELECT
  pj.sku
, pj.name
, reservation.value:CHANNEL_ATP::number as channel_atp
, reservation.value:CHANNEL_NAME::string as channel
, reservation.value:RESERVATION::numeric as reservation_quantity
, pj._portable_extracted                AS snapshot_timestamp
, DATE(pj._portable_extracted)          AS snapshot_date
FROM
  parsed_json pj
CROSS JOIN LATERAL FLATTEN(INPUT => network_balances_parsed:RESERVATIONS:CHANNELS) reservation