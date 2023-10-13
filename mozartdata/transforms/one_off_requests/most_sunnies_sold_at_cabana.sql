select 
  order_id_edw,
  channel,
  quantity_sold,
  timestamp_transaction_pst
  
from 
  dim.orders

WHERE
  channel = 'Cabana' and
  timestamp_transaction_pst > '2023-01-01T00:00:00-00:00'
  

order by quantity_sold desc
limit 100