# Issue/Summary

# Solution

# QC

# PR Checklist
- [ ] Is this a new base table? Did you include the root CTE?
root code:
```
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
```
