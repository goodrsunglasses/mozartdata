/*
This is a 1 time snapshot of fact.customer_ns_map to capture the 2024 tiers and doors associated with NS customers.
Snapshot was originally taken on 1/13/2025.

However, we found issues with Patrick Temple and Public Lands. So new snapshot is being taken on 1/15/2025 after making those fixes.

Manual adjustment to move Patrick Temple to Fleet Feet. This was done in PR #103, but we are making a manual adjustment here for snapshot purposes, so we don't have to run the pipeline again.

Update: uploaded a copy of this table as a CSV. Repointing the transform to point at the csv, so we can resolve the false/positive pipeline issues.
*/

SELECT
  *
from
  csvs.customer_tier_snapshot_2024
