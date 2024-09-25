SELECT ref.id      as refund_id,
       ref.created_at,
       'Goodr.com' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id        refund_line_id,
       line.quantity,
       line.subtotal,
       line.order_line_id
FROM shopify.refund ref
         left outer join shopify.order_line_refund line on line.refund_id = ref.id
         left outer join shopify.order_line ord on ord.id = line.order_line_id
UNION ALL
SELECT ref.id      as refund_id,
       ref.created_at,
       'Specialty' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id        refund_line_id,
       line.quantity,
       line.subtotal,
       line.order_line_id
FROM specialty_shopify.refund ref
         left outer join specialty_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join specialty_shopify.order_line ord on ord.id = line.order_line_id

UNION ALL
SELECT ref.id          as refund_id,
       ref.created_at,
       'Specialty CAN' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id            refund_line_id,
       line.quantity,
       line.subtotal,
       line.order_line_id
FROM sellgoodr_canada_shopify.refund ref
         left outer join sellgoodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join sellgoodr_canada_shopify.order_line ord on ord.id = line.order_line_id

UNION ALL
SELECT ref.id     as refund_id,
       ref.created_at,
       'Goodr.ca' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id       refund_line_id,
       line.quantity,
       line.subtotal,
       line.order_line_id
FROM goodr_canada_shopify.refund ref
         left outer join goodr_canada_shopify.order_line_refund line on line.refund_id = ref.id
         left outer join goodr_canada_shopify.order_line ord on ord.id = line.order_line_id

UNION ALL
SELECT ref.id   as refund_id,
       ref.created_at,
       'Cabana' as source,
       ref.note,
       ref.order_id,
       ord.sku,
       ord.name,
       line.id     refund_line_id,
       line.quantity,
       line.subtotal,
       line.order_line_id
FROM cabana.refund ref
         left outer join cabana.order_line_refund line on line.refund_id = ref.id
         left outer join cabana.order_line ord on ord.id = line.order_line_id
