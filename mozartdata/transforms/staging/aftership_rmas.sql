select
    'USA - returns + 3rd party'                                                      as aftership_org
  , us_returns_3p_warranties.id                                                      as aftership_id
  , us_returns_3p_warranties.rma_number
  , us_returns_3p_warranties._order:ORDER_NUMBER::varchar                            as original_order_id_edw
  , us_returns_3p_warranties._order:EXTERNAL_ID::varchar                             as original_order_id_shopify
  , us_returns_3p_warranties.created_at
  , us_returns_3p_warranties.expired_at
  , us_returns_3p_warranties.approval_status
  , us_returns_3p_warranties.approved_at
  , us_returns_3p_warranties.auto_approved
  , us_returns_3p_warranties.rejected_at
  , us_returns_3p_warranties.auto_rejected
  , us_returns_3p_warranties.reject_reason
  , us_returns_3p_warranties._order:CUSTOMER:EMAILS[0]::varchar                      as customer_email
  , us_returns_3p_warranties._order:PLACED_AT::timestamp                             as original_order_placed_at
  , us_returns_3p_warranties._order:STORE:EXTERNAL_ID::varchar                       as original_order_store
  , us_returns_3p_warranties.exchange:_ORDER:ORDER_NUMBER::varchar                   as exchange_order_number
  , us_returns_3p_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:AMOUNT::float     as exchange_total_incl_tax_amount
  , us_returns_3p_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:CURRENCY::varchar as exchange_total_incl_tax_currency
  , us_returns_3p_warranties.exchange:TAX_TOTAL:AMOUNT::float                        as exchange_tax_total
  , us_returns_3p_warranties.exchange:TAX_TOTAL:CURRENCY::varchar                    as exchange_tax_currency
  , us_returns_3p_warranties.return_method:NAME::varchar                             as return_method_name
  , us_returns_3p_warranties.return_method:RULE:NAME::varchar                        as return_method_rule_name
  , us_returns_3p_warranties.return_method:RULE:TYPE::varchar                        as return_method_rule_type
  , us_returns_3p_warranties.return_method:RULE:ZONE:NAME::varchar                   as return_method_rule_zone
  , us_returns_3p_warranties.return_total_including_tax:AMOUNT::float                as return_total_with_tax_amount
  , us_returns_3p_warranties.return_total_including_tax:CURRENCY::varchar            as return_total_with_tax_currency
  , us_returns_3p_warranties.return_tax:AMOUNT::float                                as return_tax_amount
  , us_returns_3p_warranties.return_tax:CURRENCY::varchar                            as return_tax_currency
  , us_returns_3p_warranties.shipments[0]:SLUG::varchar                              as shipment_slug
  , us_returns_3p_warranties.shipments[0]:TRACKING_NUMBER::varchar                   as shipment_tracking_number
  , us_returns_3p_warranties.shipments[0]:TRACKING_STATUS::varchar                   as shipment_tracking_status
  , us_returns_3p_warranties.shipments[0]:LABEL:TOTAL_CHARGE:AMOUNT::float           as shipment_cost
  , us_returns_3p_warranties.shipments[0]:LABEL:TOTAL_CHARGE:CURRENCY::varchar       as shipment_currency
  , us_returns_3p_warranties.receivings[0]:RECEIVED_AT::timestamp                    as return_received_at
  , us_returns_3p_warranties.auto_received
  , us_returns_3p_warranties.refunded_at
  , us_returns_3p_warranties.estimated_refund_total:AMOUNT::float                    as est_refund_amount
  , us_returns_3p_warranties.estimated_refund_total:CURRENCY::varchar                as est_refund_currency
  , us_returns_3p_warranties.refunded_total:AMOUNT::float                            as refund_amount_total
  , us_returns_3p_warranties.refunded_total:CURRENCY::varchar                        as refund_currency
  , us_returns_3p_warranties.refund_destination
  , us_returns_3p_warranties.auto_refunded
  , us_returns_3p_warranties.checkout_total:AMOUNT::float                            as checkout_upsell_total
  , us_returns_3p_warranties.checkout_total:CURRENCY::string                         as checkout_upsell_currency
  , us_returns_3p_warranties.resolved_at
  , us_returns_3p_warranties.auto_resolved
from
    aftership_returns_usa_and_3rd_party_warranties_portable.returns as us_returns_3p_warranties
union all
select
    'Canada - returns + 3rd party'                                                    as aftership_org
  , can_returns_3p_warranties.id                                                      as aftership_id
  , can_returns_3p_warranties.rma_number
  , can_returns_3p_warranties._order:ORDER_NUMBER::varchar                            as original_order_id_edw
  , can_returns_3p_warranties._order:EXTERNAL_ID::varchar                             as original_order_id_shopify
  , can_returns_3p_warranties.created_at
  , null                                                                              as expired_at
  , can_returns_3p_warranties.approval_status
  , can_returns_3p_warranties.approved_at
  , can_returns_3p_warranties.auto_approved
  , can_returns_3p_warranties.rejected_at
  , can_returns_3p_warranties.auto_rejected
  , can_returns_3p_warranties.reject_reason
  , can_returns_3p_warranties._order:CUSTOMER:EMAILS[0]::varchar                      as customer_email
  , can_returns_3p_warranties._order:PLACED_AT::timestamp                             as original_order_placed_at
  , can_returns_3p_warranties._order:STORE:EXTERNAL_ID::varchar                       as original_order_store
  , can_returns_3p_warranties.exchange:_ORDER:ORDER_NUMBER::varchar                   as exchange_order_number
  , can_returns_3p_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:AMOUNT::float     as exchange_total_incl_tax_amount
  , can_returns_3p_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:CURRENCY::varchar as exchange_total_incl_tax_currency
  , can_returns_3p_warranties.exchange:TAX_TOTAL:AMOUNT::float                        as exchange_tax_total
  , can_returns_3p_warranties.exchange:TAX_TOTAL:CURRENCY::varchar                    as exchange_tax_currency
  , can_returns_3p_warranties.return_method:NAME::varchar                             as return_method_name
  , can_returns_3p_warranties.return_method:RULE:NAME::varchar                        as return_method_rule_name
  , can_returns_3p_warranties.return_method:RULE:TYPE::varchar                        as return_method_rule_type
  , can_returns_3p_warranties.return_method:RULE:ZONE:NAME::varchar                   as return_method_rule_zone
  , can_returns_3p_warranties.return_total_including_tax:AMOUNT::float                as return_total_with_tax_amount
  , can_returns_3p_warranties.return_total_including_tax:CURRENCY::varchar            as return_total_with_tax_currency
  , can_returns_3p_warranties.return_tax:AMOUNT::float                                as return_tax_amount
  , can_returns_3p_warranties.return_tax:CURRENCY::varchar                            as return_tax_currency
  , can_returns_3p_warranties.shipments[0]:SLUG::varchar                              as shipment_slug
  , can_returns_3p_warranties.shipments[0]:TRACKING_NUMBER::varchar                   as shipment_tracking_number
  , can_returns_3p_warranties.shipments[0]:TRACKING_STATUS::varchar                   as shipment_tracking_status
  , can_returns_3p_warranties.shipments[0]:LABEL:TOTAL_CHARGE:AMOUNT::float           as shipment_cost
  , can_returns_3p_warranties.shipments[0]:LABEL:TOTAL_CHARGE:CURRENCY::varchar       as shipment_currency
  , can_returns_3p_warranties.receivings[0]:RECEIVED_AT::timestamp                    as return_received_at
  , can_returns_3p_warranties.auto_received
  , can_returns_3p_warranties.refunded_at
  , can_returns_3p_warranties.estimated_refund_total:AMOUNT::float                    as est_refund_amount
  , can_returns_3p_warranties.estimated_refund_total:CURRENCY::varchar                as est_refund_currency
  , can_returns_3p_warranties.refunded_total:AMOUNT::float                            as refund_amount_total
  , can_returns_3p_warranties.refunded_total:CURRENCY::varchar                        as refund_currency
  , can_returns_3p_warranties.refund_destination
  , can_returns_3p_warranties.auto_refunded
  , can_returns_3p_warranties.checkout_total:AMOUNT::float                            as checkout_upsell_total
  , can_returns_3p_warranties.checkout_total:CURRENCY::string                         as checkout_upsell_currency
  , can_returns_3p_warranties.resolved_at
  , can_returns_3p_warranties.auto_resolved
from
    aftership_returns_canada_and_3rd_party_warranties_portable.returns as can_returns_3p_warranties
union all
select
    'USA - warranty'                                                       as aftership_org
  , usa_warranties.id                                                      as aftership_id
  , usa_warranties.rma_number
  , usa_warranties._order:ORDER_NUMBER::varchar                            as original_order_id_edw
  , usa_warranties._order:EXTERNAL_ID::varchar                             as original_order_id_shopify
  , usa_warranties.created_at
  , usa_warranties.expired_at
  , usa_warranties.approval_status
  , usa_warranties.approved_at
  , usa_warranties.auto_approved
  , usa_warranties.rejected_at
  , usa_warranties.auto_rejected
  , usa_warranties.reject_reason
  , usa_warranties._order:CUSTOMER:EMAILS[0]::varchar                      as customer_email
  , usa_warranties._order:PLACED_AT::timestamp                             as original_order_placed_at
  , usa_warranties._order:STORE:EXTERNAL_ID::varchar                       as original_order_store
  , usa_warranties.exchange:_ORDER:ORDER_NUMBER::varchar                   as exchange_order_number
  , usa_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:AMOUNT::float     as exchange_total_incl_tax_amount
  , usa_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:CURRENCY::varchar as exchange_total_incl_tax_currency
  , usa_warranties.exchange:TAX_TOTAL:AMOUNT::float                        as exchange_tax_total
  , usa_warranties.exchange:TAX_TOTAL:CURRENCY::varchar                    as exchange_tax_currency
  , usa_warranties.return_method:NAME::varchar                             as return_method_name
  , usa_warranties.return_method:RULE:NAME::varchar                        as return_method_rule_name
  , usa_warranties.return_method:RULE:TYPE::varchar                        as return_method_rule_type
  , usa_warranties.return_method:RULE:ZONE:NAME::varchar                   as return_method_rule_zone
  , usa_warranties.return_total_including_tax:AMOUNT::float                as return_total_with_tax_amount
  , usa_warranties.return_total_including_tax:CURRENCY::varchar            as return_total_with_tax_currency
  , usa_warranties.return_tax:AMOUNT::float                                as return_tax_amount
  , usa_warranties.return_tax:CURRENCY::varchar                            as return_tax_currency
  , usa_warranties.shipments[0]:SLUG::varchar                              as shipment_slug
  , usa_warranties.shipments[0]:TRACKING_NUMBER::varchar                   as shipment_tracking_number
  , usa_warranties.shipments[0]:TRACKING_STATUS::varchar                   as shipment_tracking_status
  , usa_warranties.shipments[0]:LABEL:TOTAL_CHARGE:AMOUNT::float           as shipment_cost
  , usa_warranties.shipments[0]:LABEL:TOTAL_CHARGE:CURRENCY::varchar       as shipment_currency
  , usa_warranties.receivings[0]:RECEIVED_AT::timestamp                    as return_received_at
  , usa_warranties.auto_received
  , usa_warranties.refunded_at
  , usa_warranties.estimated_refund_total:AMOUNT::float                    as est_refund_amount
  , usa_warranties.estimated_refund_total:CURRENCY::varchar                as est_refund_currency
  , usa_warranties.refunded_total:AMOUNT::float                            as refund_amount_total
  , usa_warranties.refunded_total:CURRENCY::varchar                        as refund_currency
  , usa_warranties.refund_destination
  , usa_warranties.auto_refunded
  , usa_warranties.checkout_total:AMOUNT::float                            as checkout_upsell_total
  , usa_warranties.checkout_total:CURRENCY::string                         as checkout_upsell_currency
  , usa_warranties.resolved_at
  , usa_warranties.auto_resolved
from
    aftership_usa_warranties_portable.returns as usa_warranties
union all
select
    'Canada - warranty'                                                    as aftership_org
  , can_warranties.id                                                      as aftership_id
  , can_warranties.rma_number
  , can_warranties._order:ORDER_NUMBER::varchar                            as original_order_id_edw
  , can_warranties._order:EXTERNAL_ID::varchar                             as original_order_id_shopify
  , can_warranties.created_at
  , null                                                                   as expired_at
  , can_warranties.approval_status
  , can_warranties.approved_at
  , can_warranties.auto_approved
  , null                                                                   as rejected_at
  , null                                                                   as auto_rejected
  , null                                                                   as reject_reason
  , can_warranties._order:CUSTOMER:EMAILS[0]::varchar                      as customer_email
  , can_warranties._order:PLACED_AT::timestamp                             as original_order_placed_at
  , can_warranties._order:STORE:EXTERNAL_ID::varchar                       as original_order_store
  , can_warranties.exchange:_ORDER:ORDER_NUMBER::varchar                   as exchange_order_number
  , can_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:AMOUNT::float     as exchange_total_incl_tax_amount
  , can_warranties.exchange:EXCHANGE_TOTAL_INCLUDING_TAX:CURRENCY::varchar as exchange_total_incl_tax_currency
  , can_warranties.exchange:TAX_TOTAL:AMOUNT::float                        as exchange_tax_total
  , can_warranties.exchange:TAX_TOTAL:CURRENCY::varchar                    as exchange_tax_currency
  , can_warranties.return_method:NAME::varchar                             as return_method_name
  , can_warranties.return_method:RULE:NAME::varchar                        as return_method_rule_name
  , can_warranties.return_method:RULE:TYPE::varchar                        as return_method_rule_type
  , can_warranties.return_method:RULE:ZONE:NAME::varchar                   as return_method_rule_zone
  , can_warranties.return_total_including_tax:AMOUNT::float                as return_total_with_tax_amount
  , can_warranties.return_total_including_tax:CURRENCY::varchar            as return_total_with_tax_currency
  , can_warranties.return_tax:AMOUNT::float                                as return_tax_amount
  , can_warranties.return_tax:CURRENCY::varchar                            as return_tax_currency
  , can_warranties.shipments[0]:SLUG::varchar                              as shipment_slug
  , can_warranties.shipments[0]:TRACKING_NUMBER::varchar                   as shipment_tracking_number
  , can_warranties.shipments[0]:TRACKING_STATUS::varchar                   as shipment_tracking_status
  , can_warranties.shipments[0]:LABEL:TOTAL_CHARGE:AMOUNT::float           as shipment_cost
  , can_warranties.shipments[0]:LABEL:TOTAL_CHARGE:CURRENCY::varchar       as shipment_currency
  , can_warranties.receivings[0]:RECEIVED_AT::timestamp                    as return_received_at
  , null                                                                   as auto_received
  , null                                                                   as refunded_at
  , can_warranties.estimated_refund_total:AMOUNT::float                    as est_refund_amount
  , can_warranties.estimated_refund_total:CURRENCY::varchar                as est_refund_currency
  , null                                                                   as refund_amount_total
  , null                                                                   as refund_currency
  , can_warranties.refund_destination
  , null                                                                   as auto_refunded
  , can_warranties.checkout_total:AMOUNT::float                            as checkout_upsell_total
  , can_warranties.checkout_total:CURRENCY::string                         as checkout_upsell_currency
  , can_warranties.resolved_at
  , can_warranties.auto_resolved
from
    aftership_canada_warranties_portable.returns as can_warranties