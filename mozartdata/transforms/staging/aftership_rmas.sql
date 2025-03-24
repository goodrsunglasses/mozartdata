/*
 Table name: staging.aftership_rmas
 Created: 3-18-2025
 Purpose: Union alls together the data from the various Portable Aftership tables - USA + 3rd Party,
    Canada + 3rd Party, US Warranty, and Canada Warranty. It does not actually have any 3rd party
    warranty data as of its creation due to that information not flowing through the API - it requires
    webhooks, which can be implemented in the future if desired.
 Schema:
    aftership_org: The organization on Aftership
    aftership_id: unique id of rma on Aftership
        Primary key
    rma_number: the main identifier for an Aftership customer request within an Aftership organization
    original_order_id_edw: the order number of the original order that is associated with the RMA.
        Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
    original_id_shopify: id as it is shows in the address bar when viewing it on the shopify website
    created_at: timestamp showing when a rma was filed
    expired_at: timestamp showing when a rma expired
    approval_status: status of RMA as defined by Aftership
    approved_at: datetime of when the RMA was approved
    auto_approved: if a rma was approved without review
    rejected_at: datetime of when a rma was rejected
    auto_rejected: if a rma was rejected without review
    reject_reason: reason a rma was rejected
    customer_email: email of the customer that submitted the rma
    original_order_placed_at: datetime original order was placed on Shopify
    original_order_store: Shopify store where order was placed
    exchange_order_number: order number on Shopify of exchange order, if any.
        Foreign key to fact.orders.order_id_edw and fact.aftership_rma_items.original_order_id_edw
    exchange_total_incl_tax_amount: total value of exchange order including tax
    exchange_total_incl_tax_currency: type of currency exchange value is in
    exchange_tax_total: total value of exchange tax
    exchange_tax_currency: currency of exchange tax
    return_method_name: the method of return - this can be very ambiguous
    return_method_rule_name: this is the rule applied to determine return method. It is more specific
    return_method_rule_type: unknown
    return_method_rule_zone: unknown
    return_total_with_tax_amount: the total value of the refund or return including tax
    return_total_with_tax_currency: the currency the return_total is in
    return_tax_amount: the tax value of the return or refund
    return_tax_currency: the currency the tax amount is in
    shipment_slug: carrier for the return, if any
    shipment_tracking_number: tracking number of return, is null until slug receives package. Likely connects
        to fulfillment tables but not sure how at this time.
        todo: add boolean in relevant fulfillment table
    shipment_tracking_status: status of shipment for return
    shipment_cost: cost of shipment for return
    shipment_currency: currency of shipment cost
    return_received_at: datetime shipment of return was received
    auto_received: if shipment was received without review
    refunded_at: datetime refund was processed
    est_refund_amount: estimated refund value
    est_refund_currency: currency estimated refund value is in
    refund_amount_total: actually refunded amount
    refund_currency: currency actual refund is in
    refund_destination: where the refund will be deposited
    auto_refunded: indicates if refund was issued without review
    checkout_upsell_total: total value of an upsell
    checkout_upsell_currency: currency upsell is in
    resolved_at: datetime rma was resolved
    auto_resolved: indicated if it was processed without review
 */
with
  root_table as (
    select
        *
    from
        mozart.pipeline_root_table
    )

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