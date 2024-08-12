/*
The point of this transform is to create an incremental build (aka snapshot) of stord_facility_inventory
This transform is setup as an incremental build
*/
SELECT
  sfi.sku
, sfi.name                               AS display_name
, sfi.facility_id                        AS location_id_stord
, sfi.facility_alias                     AS location_name_stord
, sfi.allocated
, sfi.available
, sfi.damaged
, sfi.incoming
, sfi.locked
, sfi.base_unit
, sfi.inventory_alerts
, sfi.inventory_alerts:"OUT_OF_STOCK"    AS out_of_stock
, sfi.inventory_alerts:"REORDER_WARNING" AS reorder_warning
, sfi._portable_extracted                AS snapshot_timestamp
, DATE(sfi._portable_extracted)          AS snapshot_date
FROM
  stord.STORD_FACILITY_INVENTORY_8589936822 sfi
