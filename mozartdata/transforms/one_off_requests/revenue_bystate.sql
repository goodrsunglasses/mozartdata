/*
caveats to the code below:
I was able to grab shipping state with the caveat that it was the shipping state associated with the record which had the GL activity. confusing wording.

But let's say the Cash Sale has revenue GL impact, and the shipping state is CA. But the IF (which doesn't have revenue impact) has a shipping state of PA. 
I would report CA. I haven't done an audit, but I would nope 99% of the time these are the same state. I've seen cases where the address is slightly different Street instead of St for example.

With more time, I could grab the IF date (especially with some of the parent transaction work Kaden and I have been doing) if that's necessary.

What I could NOT get is the location we shipped from. I can pull location from the order, but its' not perfect, since orders can be sourced from multiple DCs, 
and we don't have a good way (today) to break down where each item was sourced from, and then associate that to it's portion of the GL impact. (oof :cold_sweat: thinking about it)

Also note: you have to run this in snowflake in order to export. It is too many rows for mozart or sheet sync.
*/

with orders as
  (
SELECT
 gt.order_id_edw  
, gt.transaction_id_ns
, gt.transaction_number_ns
, o.location
, gt.channel
, ol.record_type
, t.shippingaddress
,  sum(gt.net_amount) net_amount
FROM
  fact.gl_transaction gt
inner join
  netsuite.transaction t
  on t.id = gt.transaction_id_ns
left join
  fact.order_line ol
  on gt.transaction_id_ns = ol.transaction_id_ns
left join
  fact.orders o
  on ol.order_id_edw = o.order_id_edw
left join
  fact.purchase_orders po
  on ol.order_id_edw = po.order_id_edw
WHERE
  gt.account_number between 4000 and 4999
  and YEAR(TO_DATE(gt.posting_period,'Mon YYYY'))='2022'
  and gt.posting_flag 
group by
 gt.order_id_edw  
, gt.transaction_id_ns
, gt.transaction_number_ns
, o.location
, gt.channel
, ol.record_type
, t.shippingaddress
  )
  SELECT
    o.*
  , coalesce(isa.state, csa.state, cra.state, cria.state,'UNKNOWN') shipping_state
  FROM
    orders o
  left join
    netsuite.invoiceshippingaddress isa
    on isa.nkey = o.shippingaddress
    and o.record_type = 'invoice'
  left join
    netsuite.cashsaleshippingaddress csa
    on csa.nkey = o.shippingaddress
    and o.record_type = 'cashsale'
  left join
    netsuite.cashsaleshippingaddress cra
        on cra.nkey = o.shippingaddress
    and o.record_type = 'cashrefund'
    left join
    netsuite.invoiceshippingaddress cria
        on cria.nkey = o.shippingaddress
    and o.record_type = 'cashrefund'
    where net_amount != 0