SELECT
       ref.refund_id as refund_id_shopify,
       ref.order_id as order_id_shopify,
       o.order_id_edw,
       ref.created_at,
       ref.store,
       ref.amount*-1 as amount_adjustment,
       ref.tax_amount*-1 as amount_adjustment_tax,
       ref.total_adj_amnt*-1    as amount_adjustment_total,
       ref.note,
       ref.reason
from
  staging.shopify_refund_order_adjustment ref
  left join dim.orders o on ref.order_id = o.order_id_shopify
where order_id_edw = 'G1509643'