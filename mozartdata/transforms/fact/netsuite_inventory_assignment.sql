/*
Purpose: This table has the bin inventory detail information used for Transfer Orders.

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
  ia.id as inventory_assignment_id_ns
, abs(ia.quantity) as quantity
, ia.transaction as transaction_id_ns
, ia.transactionline as transaction_line_id_ns
, ia.bin as bin_id_ns
, b.binnumber as bin_number
from
  netsuite.inventoryassignment ia
left join
  netsuite.bin b
  on ia.bin = b.id
where
  ia._fivetran_deleted = false
