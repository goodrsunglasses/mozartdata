SELECT
    o.channel,
    date_trunc(month,o.sold_date) sold_month,
    p.color_frame,
    p.frame_artwork,
    p.design_tier,
    p.display_name,
    p.merchandise_class,
    p.color_lens_finish,
    p.sku,
    p.family,
    sum(oi.revenue) revenue,
    sum(oi.quantity_sold) quantity_sold
FROM
    fact.order_item AS oi
JOIN
    fact.orders AS o ON oi.order_id_edw = o.order_id_edw
JOIN
    dim.product AS p ON oi.product_id_edw = p.product_id_edw
WHERE
    o.sold_date > '2021-12-31'
group by
    o.channel,
    p.sku,
    p.merchandise_class,
    date_trunc(month,o.sold_date),
    p.color_frame,
    p.frame_artwork,
    p.design_tier,
    p.color_lens_finish,
    p.display_name,
    p.family