/*
WARNING! DO NOT SCHEDULE THIS TRANSFORM TO RUN! IT IS A ONE-TIME RUN ONLY!

This is a 1 time snapshot of fact.customer_ns_map to capture the 2024 tiers and doors associated with NS customers.
Snapshot was taken on 1/13/2025
*/
select
  *,
  current_date as snapshot_date
from
  fact.customer_ns_map
where
  tier is not null or doors is not null