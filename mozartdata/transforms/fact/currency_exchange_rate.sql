/*
Purpose: show the exchange rate for day for USD to EUR, GBP and CAD.
One row per day per currency.

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
  cr.id as currency_exchange_rate_id_ns
, cr.basecurrency as base_currency_id_ns
, bc.symbol as base_currency_abbreviation
, cr.transactioncurrency as transaction_currency_id_ns
, tc.symbol as transaction_currency_abbreviation
, date(cr.effectivedate) as effective_date
, cr.exchangerate as exchange_rate
from
  netsuite.currencyrate cr
left join
  netsuite.currency bc
  on cr.BASECURRENCY = bc.ID
left join
  netsuite.currency tc
  on cr.TRANSACTIONCURRENCY = tc.ID