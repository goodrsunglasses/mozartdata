select
  *
from
  fact.customer_ns_map
where
  tier is not null or doors is not null