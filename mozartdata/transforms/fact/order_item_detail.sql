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
                , sum(case when gt.account_number in (5000, 5100, 5110, 5200) then gt.net_amount else 0 end) amount_cogs
                , sum(case
                        when gt.account_number between 4000 and 4999 or gt.account_number like '220%'
                          then gt.net_amount
                        else 0 end)                                                                          amount_paid
           from fact.gl_transaction gt
           where (gt.account_number between 4000 and 4999
              or gt.account_number in (5000, 5100, 5110, 5200)
              or gt.account_number like '220%')
           group by gt.transaction_id_ns
                  , gt.item_id_ns)

   SELECT parents.order_id_edw
        , staging.order_id_ns
        , staging.transaction_id_ns
        , parents.is_parent
        , order_item_detail_id
        , product_id_edw
        , staging.item_id_ns
        , transaction_created_timestamp_pst
        , transaction_created_date_pst
        , staging.record_type
        , full_status
        , item_type
        , plain_name
        , coalesce(na.amount_revenue,0) amount_revenue
        , coalesce(na.amount_product,0) amount_product
        , coalesce(na.amount_discount,0) amount_discount
        , coalesce(na.amount_shipping,0) amount_shipping
        , coalesce(nullif(na.amount_refunded,-0),na.amount_refunded,0) amount_refunded
        , coalesce(na.amount_tax,0) amount_tax
        , coalesce(na.amount_paid,0) amount_paid
        , coalesce(na.amount_cogs,0) amount_cogs
        , total_quantity
        , quantity_invoiced
        , quantity_backordered
        , unit_rate
        , rate
        , gross_profit_estimate
        , cost_estimate
        , location
        , createdfrom
        , staging.warranty_order_id_ns
        , exception_flag
   FROM dim.parent_transactions parents
          LEFT OUTER JOIN staging.order_item_detail staging ON staging.transaction_id_ns = parents.transaction_id_ns
          LEFT OUTER JOIN exceptions.order_item_detail exceptions
                          ON exceptions.transaction_id_ns = parents.transaction_id_ns
          LEFT OUTER JOIN net_amount na
                          on staging.transaction_id_ns = na.transaction_id_ns and staging.item_id_ns = na.item_id_ns
   WHERE exception_flag = FALSE
