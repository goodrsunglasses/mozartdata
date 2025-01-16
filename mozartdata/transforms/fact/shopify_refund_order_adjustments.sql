select
    ref.refund_id           as refund_id_shopify
    , ref.order_id            as order_id_shopify
    , o.order_id_edw
    , ref.created_at
    , ref.store
    , ref.amount * -1         as amount_adjustment
    , ref.tax_amount * -1     as amount_adjustment_tax
    , ref.total_adj_amnt * -1 as amount_adjustment_total
    , ref.note
    , ref.reason
from
    staging.shopify_refund_order_adjustments as ref
left join
    staging.shopify_orders                   as o
    on
    o.order_id_shopify = ref.order_id