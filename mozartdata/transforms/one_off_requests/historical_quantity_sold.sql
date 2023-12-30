with
  shopify as
  (
SELECT
  date_trunc(year,date(o.created_at)) order_year
, sum(ol.quantity) quantity
FROM
  shopify."ORDER" o
INNER JOIN
  shopify.order_line ol
  on o.id = ol.order_id
  where order_year<='2021-01-01'
  group by  date_trunc(year,date(o.created_at))
order by
  order_year
), specialty as
  (
SELECT
  date_trunc(year,date(o.created_at)) order_year
, sum(ol.quantity) quantity
FROM
  specialty_shopify."ORDER" o
LEFT JOIN
  specialty_shopify.order_line ol
  on o.id = ol.order_id
  where order_year<='2021-01-01'
  group by  date_trunc(year,date(o.created_at))
order by
  order_year
)
SELECT
  date_trunc(year,o.sold_date) order_year
  , sum(quantity_sold) quantity
FROM
  fact.orders o
where channel = 'Goodr.com'
group by
  date_trunc(year,o.sold_date)
union all
(select s.order_year, s.quantity+ss.quantity from shopify s inner join specialty ss on s.order_year = ss.order_year)
order by order_year