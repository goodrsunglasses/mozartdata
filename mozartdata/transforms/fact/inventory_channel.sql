SELECT distinct
  sku
, name as display_name
, channel
, channel_atp as quantity_available
, reservation_quantity
, snapshot_timestamp
, snapshot_date
from
  fact.stord_inventory_reservations
where
  sku = 'G00432-RTG-BL1-NR'
and snapshot_date >= current_date()

select * from fact.inventory_location where sku = 'G00432-RTG-BL1-NR' and snapshot_date=  '2024-09-12'

select
  sku
  , name as display_name
  , channel
  , channel_atp - sum(reservation_quantity) as unreserved_quantity
  , snapshot_date
from
  fact.stord_inventory_reservations
where
  sku = 'G00432-RTG-BL1-NR'
  and snapshot_date >= current_date()
group by
  sku
 , name
  ,channel
 , channel_atp
 , snapshot_date
order by
  channel_atp DESC
-- group by
--   sku
--  , name
--  , channel_atp
--  , snapshot_date
-- order by
--   channel_atp DESC

