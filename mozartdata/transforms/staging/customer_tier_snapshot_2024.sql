/*
WARNING! DO NOT SCHEDULE THIS TRANSFORM TO RUN! IT IS A ONE-TIME RUN ONLY!

This is a 1 time snapshot of fact.customer_ns_map to capture the 2024 tiers and doors associated with NS customers.
Snapshot was originally taken on 1/13/2025.

However, we found issues with Patrick Temple and Public Lands. So new snapshot is being taken on 1/15/2025 after making those fixes.

Manual adjustment to move Patrick Temple to Fleet Feet. This was done in PR #103, but we are making a manual adjustment here for snapshot purposes, so we don't have to run the pipeline again.
*/
/*
Commenting out select statement to reduce risk of data erroneously being updated.

select
  * exclude tier,
  case when lower(company_name) = 'patrick temple' then 'Fleet Feet' else tier end as tier,
  current_date as snapshot_date
from
  fact.customer_ns_map
where
  tier is not null or doors is not null

*/