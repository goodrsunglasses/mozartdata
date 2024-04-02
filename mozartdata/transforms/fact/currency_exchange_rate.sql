select
  cr.id as currency_exchange_rate_id_ns
, cr.basecurrency as base_currency_id_ns
, bc.symbol as base_currency_abbreviation
, cr.transactioncurrency as transaction_currency_id_ns
, tc.symbol as transaction_currency_abbreviation
, date(cr.effectivedate) as effective_date
, cr.exchangerate as exchange_rate
from
  NETSUITE.CURRENCYRATE cr
left join
  NETSUITE.CURRENCY bc
  on cr.BASECURRENCY = bc.ID
left join
  NETSUITE.CURRENCY tc
  on cr.TRANSACTIONCURRENCY = tc.ID
