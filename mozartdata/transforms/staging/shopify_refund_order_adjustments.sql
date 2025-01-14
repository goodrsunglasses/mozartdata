/*
Purpose: to show the refund changes and their reasons from all shopify stores.
One row per refund per order per store.

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
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Goodr.com'                    as store,
       ref.note,
       ref.order_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM shopify.refund ref
         inner join shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Specialty'                    as store,
       ref.note,
       ref.order_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM SPECIALTY_SHOPIFY.refund ref
         inner join SPECIALTY_SHOPIFY.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Specialty CAN' as store,
       ref.note,
       ref.order_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM sellgoodr_canada_shopify.refund ref
         inner join sellgoodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Goodr.ca' as store,
       ref.note,
       ref.order_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM goodr_canada_shopify.refund ref
         inner join goodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Cabana' as store,
       ref.note,
       ref.order_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM cabana.refund ref
         inner join cabana.order_adjustment adj on adj.refund_id = ref.id