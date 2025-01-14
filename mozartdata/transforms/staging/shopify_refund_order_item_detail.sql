/*
Purpose: to show the detailed order information associated with each refund
in each shopify store.
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
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id
FROM shopify.refund ref
         left outer join shopify.order_line_refund line on line.refund_id = ref.id
         left outer join shopify.order_line ord on ord.id = line.order_line_id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Specialty'                    as store,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id
FROM SPECIALTY_SHOPIFY.refund ref
         left outer join SPECIALTY_SHOPIFY.order_line_refund line on line.refund_id = ref.id
         left outer join SPECIALTY_SHOPIFY.order_line ord on ord.id = line.order_line_id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Specialty CAN' as store,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id
FROM sellgoodr_canada_shopify.refund ref
         left outer join sellgoodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join sellgoodr_canada_shopify.order_line ord on ord.id = line.order_line_id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Goodr.ca' as store,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id
FROM goodr_canada_shopify.refund ref
         left outer join goodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join goodr_canada_shopify.order_line ord on ord.id = line.order_line_id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Cabana' as store,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id
FROM cabana.refund ref
         left outer join cabana.order_line_refund line on line.refund_id = ref.id
         left outer join cabana.order_line ord on ord.id = line.order_line_id