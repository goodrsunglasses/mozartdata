--Just like the note on dim.company this is a bit whacky due to sourcing shopify company info as the SoT rather than a combination of NS and Shopify
with customer_based_info as (
    select * from dim.customer

     )
select
    company_id_shopify
  , company_name_shopify
  , sum(orders_count)   as orders_count_shopify
  , sum(lifetime_value) as lifetime_value_shopify
  , date(max(updated_at) )    as most_recent_order
from
    dim.company                                                       comp
    cross join lateral flatten(input =>child_customer_ids_shopify) as shop_ids
    left outer join fact.customer_shopify_map                         shopmap
        on shopmap.id = shop_ids.value
where
    company_name_shopify like 'Big Peach%'
group by
    company_id_shopify
  , company_name_shopify