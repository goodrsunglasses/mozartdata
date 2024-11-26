/*
Purpose: to show the inventory level of each item in Netsuite on any given date.
One row per bin per location per item.

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
select
  binnumber,
  committedqtyperlocation,
  committedqtyperseriallotnumber,
  committedqtyperseriallotnumberlocation,
  item,
  location,
  quantityavailable,
  quantityonhand,
  quantitypicked,
  date(_fivetran_synced) AS date_synced,
  _fivetran_synced
FROM
  netsuite.inventorybalance balance
order by _FIVETRAN_SYNCED desc