-- CREATE OR REPLACE TABLE fact.shopify_refund_order_item_detail
-- 	COPY GRANTS AS
select detail.refund_id as refund_id_shopify,
       detail.order_id as order_id_shopify,
       ord.ORDER_ID_EDW,
       detail.created_at as refund_created_timestamp,
       date(detail.created_at) as refund_created_date,
       detail.store,
       detail.amount           as amount_adjustment,--IMPORTANT any and all adjustment fields are at the ORDER level refund wise, rather than at the item level
       detail.tax_amount       as amount_adjustment_tax,
       detail.TOTAL_ADJ_AMNT   as amount_adjustment_total,
       detail.sku,
       detail.name             as display_name,
       detail.refund_line_id as refund_line_id_shopify,
       detail.quantity         as quantity_refund_line,
       detail.subtotal         as amount_refund_line_subtotal,
       detail.total_tax        as amount_refund_line_tax,
       detail.total_line_amnt  as amount_refund_line_total,
       detail.order_line_id as order_line_id_shopify,
       detail.reason                  as adjustment_reason,
       detail.note                    as refund_note
from staging.shopify_refund_order_item_detail detail
         left outer join dim.orders ord on ord.ORDER_ID_SHOPIFY = detail.ORDER_ID