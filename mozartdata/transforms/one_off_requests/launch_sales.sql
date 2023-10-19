WITH collection_cte AS (
    SELECT
        sku,
        CASE
            WHEN sku IN ('G00237-OG-LB1-RF', 'G00273-OG-RS2-RF') THEN 'RUN CHICAGO + DC'
            WHEN sku in ('G00252-OG-BO1-RF' , 'G00253-OG-GD6-RF' , 'G00254-OG-GD7-RF') then 'DAZED & CONFUSED'
            WHEN sku in ('G00287-OG-BK1-NR') then 'EXERCISE THE DEMONS'
            WHEN sku in ('G00274-OG-BK1-GR') then 'RUN NYC'
            WHEN sku in ('G00264-OG-LLB2-RF') then 'BREAKING SILENCE'
            WHEN sku in ('G00296-OG-GR1-GR' , 'G00297-OG-BR1-NR') then 'MONSTERS'
            ELSE null
        END AS collection
    FROM draft_dim.product
)

select
p.sku
,collection_cte.collection
,sum(o.amount_sold)
,count()
from
fact.orders o
inner join
fact.order_item oi
on o.order_id_edw = oi.order_id_edw
inner join
draft_dim.product p
on p.item_id_ns = oi.item_id_ns
inner JOIN
collection_cte on collection_cte.sku = p.sku
group by
p.sku,
collection_cte.collection
order by collection