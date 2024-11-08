select detail.refund_id as refund_id_shopify,
       detail.order_id as order_id_shopify,
       ord.ORDER_ID_EDW,
       detail.created_at as refund_created_timestamp,
       date(detail.created_at) as refund_created_date,
       detail.store,
       detail.sku,
       detail.name             as display_name,
       detail.refund_line_id as refund_line_id_shopify,
       detail.quantity         as quantity_refund_line,
       coalesce(detail.subtotal,0)         as amount_refund_line_subtotal,
       coalesce(detail.total_tax,0)        as amount_refund_line_tax,
       coalesce(detail.total_line_amnt,0)  as amount_refund_line_total,
       detail.order_line_id as order_line_id_shopify
from staging.shopify_refund_order_item_detail detail
         left outer join dim.orders ord on ord.ORDER_ID_SHOPIFY = detail.ORDER_ID