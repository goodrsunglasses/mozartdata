/*
Purpose: The point of this transform is to create an incremental build (aka snapshot) of stord_network_inventory
This transform is setup as an incremental build.
One row per sku per date

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
SELECT
  sni.sku
, sni.name                               AS display_name
, sni.unit
, sni.network_balances
, cast(sni.network_balances:"ACCEPTED" as integer) AS accepted
, cast(sni.network_balances:"ALLOCATED" as integer) AS allocated
, cast(sni.network_balances:"AVAILABLE" as integer) AS available
, cast(sni.network_balances:"BACKORDERED" as integer) AS backordered
, cast(sni.network_balances:"BACKORDERED_AVAILABLE" as integer) AS backordered_available
, cast(sni.network_balances:"COMMITTED" as integer) AS committed
, cast(sni.network_balances:"DAMAGED" as integer) AS damaged
, cast(sni.network_balances:"INCOMING" as integer) AS incoming
, cast(sni.network_balances:"LOCKED" as integer) AS locked
, cast(sni.network_balances:"ON_HOLD" as integer) AS on_hold
, cast(sni.network_balances:"OTHER" as integer) AS other
, cast(sni.network_balances:"QUARANTINED" as integer) AS quarantined
, cast(sni.network_balances:"RECEIVING" as integer) AS receiving
--, cast(sni.network_balances:"RESERVATIONS" as integer) AS reservations
, cast(sni.network_balances:"TOTAL_ON_HAND" as integer) AS total_on_hand
, cast(sni.network_balances:"UNLOCKED" as integer) AS unlocked
, sni._portable_extracted                AS snapshot_timestamp
, DATE(sni._portable_extracted)          AS snapshot_date
FROM
  stord.stord_network_inventory_8589936822 sni
