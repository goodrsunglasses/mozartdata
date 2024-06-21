
select cust.CUSTOMER_ID_EDW,
       cust.PRIMARY_IDENTIFIER,
       cust.method,
       ns.ENTITY_TITLE,
       ns.FIRST_ORDER_DATE as FIRSTORDERDATE_NS,
       ns.FIRST_SALE_DATE as FIRSTSALEDATE_NS,
       ns.LAST_ORDER_DATE as LASTORDERDATE_NS,
       ns.LAST_SALE_DATE as LASTSALEDATE_NS,
        sum(shop.ORDERS_COUNT) as total_order_count_shop,
        sum(LIFETIME_VALUE) as total_VALUE_shop
from dim.CUSTOMER cust
         left outer join fact.CUSTOMER_NS_MAP ns
                         on ns.CUSTOMER_ID_EDW = cust.CUSTOMER_ID_EDW -- This is allowed because as per our QC the two are pretty 1:1
         left outer join fact.CUSTOMER_SHOPIFY_MAP shop on shop.CUSTOMER_ID_EDW = cust.CUSTOMER_ID_EDW
group by cust.CUSTOMER_ID_EDW,
         cust.PRIMARY_IDENTIFIER,
         cust.method,
         ns.ENTITY_TITLE,
       ns.FIRST_ORDER_DATE ,
       ns.FIRST_SALE_DATE ,
       ns.LAST_ORDER_DATE,
       ns.LAST_SALE_DATE