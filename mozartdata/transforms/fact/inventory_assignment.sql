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
