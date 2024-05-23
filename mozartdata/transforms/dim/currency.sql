select
    c.id as currency_id_ns
  , c.name as name
  , c.symbol as abbreviation
  , c.displaysymbol as display_symbol
  , case when c.isinactive = 'T' then false else true end is_active_flag
  , case when c.isbasecurrency = 'T' then true else false end is_base_currency_flag
from
  NETSUITE.CURRENCY c