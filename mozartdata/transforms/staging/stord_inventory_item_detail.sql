/*
Purpose: Show detailed information regarding inventory at Stord locations.
One row per sku per facility?

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
  sia.adjusted_at       AS adjusted_timestamp
, DATE(sia.adjusted_at) AS adjusted_date
, sia.sku
, sia.name as display_name
, round(sia.previous_quantity,0) as previous_quantity
, round(sia.adjustment_quantity,0) as adjustment_quantity
, round(sia.updated_quantity,0) as updated_quantity
, sia.order_number as order_id_ns --can we call it that?
, sia.adjustment_sequence
, sia.category
, sia.expires_at        AS expiration_date
, sia.facility_id       AS location_id_stord
, sia.facility_alias    AS location_name_stord
, sia.ledger_sequence
, sia.lot_number --always null or blank
, sia.item_id           AS item_id_stord
, sia.reason
, sia.reason_code
, sia.reason_type
, sia.unit
FROM
  stord.stord_inventory_adjustments_8589936822 sia