-- CREATE OR REPLACE TABLE staging.shopify_refund_order_item_detail
-- 	COPY GRANTS AS
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Goodr.com'                    as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM shopify.refund ref
         left outer join shopify.order_line_refund line on line.refund_id = ref.id
         left outer join shopify.order_line ord on ord.id = line.order_line_id
         left outer join shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
       'Specialty'                    as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM SPECIALTY_SHOPIFY.refund ref
         left outer join SPECIALTY_SHOPIFY.order_line_refund line on line.refund_id = ref.id
         left outer join SPECIALTY_SHOPIFY.order_line ord on ord.id = line.order_line_id
         left outer join SPECIALTY_SHOPIFY.order_adjustment adj on adj.refund_id = ref.id

UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
     'Specialty CAN' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM sellgoodr_canada_shopify.refund ref
         left outer join sellgoodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join sellgoodr_canada_shopify.order_line ord on ord.id = line.order_line_id
         left outer join sellgoodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
 'Goodr.ca' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM goodr_canada_shopify.refund ref
         left outer join goodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join goodr_canada_shopify.order_line ord on ord.id = line.order_line_id
         left outer join goodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
UNION ALL
SELECT ref.id                         as refund_id,
       ref.created_at,
           'Cabana' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id                           refund_line_id,
       line.quantity,
       line.subtotal,
       line.total_tax,
       line.subtotal + line.total_tax as total_line_amnt,
       line.order_line_id,
       adj.amount,
       adj.tax_amount,
       adj.amount + adj.tax_amount    as total_adj_amnt,
       adj.reason
FROM cabana.refund ref
         left outer join cabana.order_line_refund line on line.refund_id = ref.id
         left outer join cabana.order_line ord on ord.id = line.order_line_id
         left outer join cabana.order_adjustment adj on adj.refund_id = ref.id