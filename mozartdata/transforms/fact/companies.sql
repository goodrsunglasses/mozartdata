--Just like the note on dim.company this is a bit whacky due to sourcing shopify company info as the SoT rather than a combination of NS and Shopify
select
    company_id_shopify
  , company_name_shopify
  , sum(orders_count)
  , sum(lifetime_value)
from
    dim.company                                                       comp
    cross join lateral flatten(input =>child_customer_ids_shopify) as shop_ids
    left outer join fact.customer_shopify_map                         shopmap
        on shopmap.id = shop_ids.value
where company_id_shopify = 3907846322
group by
    company_id_shopify
  , company_name_shopify