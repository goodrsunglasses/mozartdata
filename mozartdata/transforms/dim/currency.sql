/*
Purpose: show each currency accepted by our sales channels. One row per currency.

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
    c.id as currency_id_ns
  , c.name as name
  , c.symbol as abbreviation
  , c.displaysymbol as display_symbol
  , case when c.isinactive = 'T' then false else true end is_active_flag
  , case when c.isbasecurrency = 'T' then true else false end is_base_currency_flag
from
  NETSUITE.CURRENCY c