with gl_totals as (
    SELECT
        gl.order_id_ns
        ,gl.item_id_ns
        ,gl.net_amount
    FROM
        fact.gl_transaction as gl
    WHERE
        gl.channel = 'Global'
        and gl.posting_flag = 'true'
        and gl.account_number like '4%'
)

SELECT DISTINCT
    o.booked_date
    ,o.customer_id_edw
    ,CASE
        WHEN 
            o.customer_id_edw = 'c7c23b72071e13002bf5d7f62f93006f' 
            AND o.booked_date >= '2024-03-01' 
        THEN 
            'Unicorn Inc Limited'
        ELSE
            CASE
                WHEN 
                    o.customer_id_edw = 'c7c23b72071e13002bf5d7f62f93006f'  
                THEN 
                    '2Pure Ltd'
                ELSE
                    c.company_name
            END
    END as company_name
    ,o.order_id_ns
    ,oi.sku
    ,oi.plain_name
    ,p.merchandise_class
    ,oi.quantity_sold
    ,gl.net_amount
    ,sa.country
FROM
    fact.orders as o
left join
    fact.customer_ns_map as c
    on o.customer_id_edw = c.customer_id_edw
left join
    fact.order_item as oi
    on 
        o.order_id_ns = oi.order_id_ns
left join
    dim.product as p
    on 
        oi.sku = p.sku
left join
    gl_totals as gl
    on 
        oi.order_id_ns = gl.order_id_ns
        and oi.item_id_ns = gl.item_id_ns
left join
    fact.order_line as ol
    on 
        oi.order_id_ns = ol.order_id_ns
left join
    netsuite.transaction as t
    on 
        ol.transaction_id_ns = t.id
left join
    netsuite.salesordershippingaddress as sa
    on 
        t.shippingaddress = sa.nkey
WHERE
    o.channel = 'Global'
    and LOWER(ol.record_type) = 'salesorder'
    and ol.transaction_status_ns != 'Sales Order : Closed'
    and p.merchandise_class is not null
order by
    order_id_ns asc