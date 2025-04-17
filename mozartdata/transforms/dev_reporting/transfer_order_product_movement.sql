WITH
  fulfillments AS (
    SELECT
      i.transfer_order_number_ns
    , listagg(i.transaction_number_ns,',') as item_fulfillment_number
    , i.status
    , i.transaction_date as actual_shipped_date
    , i.sku
    , sum(i.total_quantity) as quantity_shipped
    , i.shipping_location
    , i.receiving_location
    , case when i.shipping_location = 'HQ DC' then 'Outbound'
        when i.receiving_location = 'HQ DC' then 'Inbound' else 'Other' end as inbound_outbound
      FROM
        fact.transfer_order_item_detail i
      WHERE
        i.record_type = 'itemfulfillment'
      GROUP BY ALL
    ),
  receipts AS (
    SELECT
      i.transfer_order_number_ns
    , listagg(i.transaction_number_ns,',') as item_receipt_number
    , i.status
    , i.transaction_date as actual_received_date
    , i.sku
    , sum(i.total_quantity) as quantity_received
    , i.shipping_location
    , i.receiving_location
    , case when i.shipping_location = 'HQ DC' then 'Outbound'
        when i.receiving_location = 'HQ DC' then 'Inbound' else 'Other' end as inbound_outbound
      FROM
        fact.transfer_order_item_detail i
      WHERE
        i.record_type = 'itemreceipt'
      GROUP BY ALL
    ),
  transfer_orders as
  (
      SELECT
        i.transfer_order_number_ns
      , i.shipping_location
      , i.receiving_location
      , case when i.shipping_location = 'HQ DC' then 'Outbound'
             when i.receiving_location = 'HQ DC' then 'Inbound' else 'Other' end as inbound_outbound
      , i.sku
      , i.transfer_order_status
      , i.transfer_order_total_quantity
      , i.transfer_order_requested_date
      , i.transfer_order_expected_ship_date as estimated_ship_date
      , i.transfer_order_expected_receipt_date as estimated_received_date

      FROM
        fact.transfer_order_item i
  )
select distinct
  t.transfer_order_number_ns
, t.shipping_location
, t.receiving_location
, t.inbound_outbound
, t.sku
, t.transfer_order_status
, t.transfer_order_total_quantity
, t.transfer_order_requested_date
, t.estimated_ship_date
, f.actual_shipped_date
, f.quantity_shipped
, t.estimated_received_date
, case
    when (t.shipping_location like 'HQ DC%' or t.receiving_location like 'HQ DC%') and  (t.shipping_location like '%ATL%' or t.receiving_location like '%ATL%') then
      dateadd(day, 8, coalesce(f.actual_shipped_date, t.estimated_ship_date))
    when (t.shipping_location like 'HQ DC%' or t.receiving_location like 'HQ DC%') and  (t.shipping_location like '%LAS%' or t.receiving_location like '%LAS%') then
      dateadd(day, 1, coalesce(f.actual_shipped_date, t.estimated_ship_date))
    end calculated_received_date
, r.actual_received_date
, r.quantity_received
from
  transfer_orders t
left join
  fulfillments f
  on t.transfer_order_number_ns = f.transfer_order_number_ns
  and t.sku = f.sku
left join
  receipts r
on t.transfer_order_number_ns = r.transfer_order_number_ns
and t .sku  = r.sku
and r.actual_received_date >= f.actual_shipped_date
where inbound_outbound != 'Other'
qualify rank() over(partition by t.transfer_order_number_ns, t.sku, f.actual_shipped_date order by f.actual_shipped_date, r.actual_received_date) =1
order by transfer_order_requested_date desc