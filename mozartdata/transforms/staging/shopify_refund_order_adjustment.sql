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
         left outer join shopify.order_adjustment adj on adj.refund_id = ref.id
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
         left outer join SPECIALTY_SHOPIFY.order_adjustment adj on adj.refund_id = ref.id
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
         left outer join sellgoodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
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
         left outer join goodr_canada_shopify.order_adjustment adj on adj.refund_id = ref.id
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
         left outer join cabana.order_adjustment adj on adj.refund_id = ref.id