-- CREATE OR REPLACE TABLE fact.order_item_detail
-- 	COPY GRANTS AS
with net_amount as
          (select gt.transaction_id_ns
                , gt.item_id_ns
                , sum(case when gt.account_number between 4000 and 4999 then gt.net_amount else 0 end)       amount_revenue
                , sum(case when gt.account_number = 4000 then gt.net_amount else 0 end)                      amount_product
                , sum(case when gt.account_number = 4110 then gt.net_amount else 0 end)                      amount_discount
                , sum(case when gt.account_number = 4050 then gt.net_amount else 0 end)                      amount_shipping
                , sum(case
                        when gt.account_number between 4210 and 4299 then gt.net_amount
                        when gt.account_number like '220%' then gt.debit_amount * -1 -- refund for sales tax
                        when gt.account_number in (4000, 4050)
                          then gt.debit_amount * -1 --Some refunds are reversing revenue accounts instead of adding to refund accounts (42*)
                        else 0 end)                                                                          amount_refunded
                , sum(case when gt.account_number like '220%' then gt.net_amount else 0 end)                 amount_tax
                , sum(case when gt.account_number like '5%' then gt.net_amount else 0 end)                   amount_cogs
                , sum(case
                        when gt.account_number between 4000 and 4999 or gt.account_number like '220%'
                          then gt.net_amount
                        else 0 end)                                                                          amount_paid
                -- The following columns are for Purchase Orders (POs)
                --handling the naturally negative balance of the liability (2310) and expense (5200) to appear positive for reporting
                , sum(case when gt.account_number = 2310 then gt.net_amount * -1 else 0 end)                 amount_billed
                , sum(case when gt.account_number = 1200 then gt.net_amount else 0 end)                      amount_inventory
                , sum(case when gt.account_number = 5200 then gt.net_amount * -1 else 0 end)                 amount_landed_costs
           from fact.gl_transaction gt
           where (gt.account_number between 4000 and 4999
              or gt.account_number like '5%'
              or gt.account_number like '220%'
              or gt.account_number in (1200,2310)) -- PO Accounts
           group by gt.transaction_id_ns
                  , gt.item_id_ns)

   SELECT parents.order_id_edw
        , staging.order_id_ns
        , staging.transaction_id_ns
        , parents.is_parent
        , staging.order_item_detail_id
        , staging.product_id_edw
        , staging.item_id_ns
        , staging.transaction_date
        , staging.transaction_created_timestamp_pst
        , staging.transaction_created_date_pst
        , staging.record_type
        , staging.full_status
        , staging.item_type
        , staging.plain_name
        , coalesce(na.amount_revenue,0) as amount_revenue
        , coalesce(na.amount_product,0) as amount_product
        , coalesce(na.amount_discount,0) as amount_discount
        , coalesce(na.amount_shipping,0) as amount_shipping
        , coalesce(nullif(na.amount_refunded,-0),na.amount_refunded,0) as amount_refunded
        , coalesce(na.amount_tax,0) as amount_tax
        , coalesce(na.amount_paid,0) as amount_paid
        , coalesce(na.amount_cogs,0) as amount_cogs
        , coalesce(na.amount_billed,0) as amount_billed
        , coalesce(na.amount_inventory,0) as amount_inventory
        , coalesce(na.amount_landed_costs,0) as amount_landed_costs
        , staging.total_quantity
        , staging.quantity_invoiced
        , staging.quantity_backordered
        , staging.unit_rate
        , staging.rate
        , staging.gross_profit_estimate
        , staging.cost_estimate
        , staging.location
        , staging.createdfrom
        , staging.SHIPPINGADDRESS
        , staging.warranty_order_id_ns
        , cnm.customer_id_edw
        , staging.CUSTOMER_ID_NS
        , cnm.tier
        , exceptions.exception_flag
        , c.name as channel
   	, staging.rate_percent
   FROM dim.parent_transactions parents
          LEFT OUTER JOIN staging.order_item_detail staging ON staging.transaction_id_ns = parents.transaction_id_ns
          LEFT OUTER JOIN exceptions.order_item_detail exceptions
                          ON exceptions.transaction_id_ns = parents.transaction_id_ns
          LEFT OUTER JOIN net_amount na
                          on staging.transaction_id_ns = na.transaction_id_ns and staging.item_id_ns = na.item_id_ns
          LEFT OUTER JOIN fact.customer_ns_map cnm
                          ON staging.customer_id_ns = cnm.customer_id_ns
          LEFT OUTER JOIN dim.channel c
                          ON c.channel_id_ns = staging.channel_id_ns
   WHERE exceptions.exception_flag = FALSE
