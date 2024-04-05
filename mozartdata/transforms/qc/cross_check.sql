SELECT order_id_edw,
       booked_date,
       booked_date_shopify,
       booked_date_ns,
       quantity_booked,
       quantity_booked_shopify,
       quantity_booked_ns,
       amount_booked,
       AMOUNT_BOOKED_SHOPIFY,
       amount_booked_ns
FROM   fact.orders
where booked_date < CURRENT_DATE()-1 and (QUANTITY_BOOKED_NS!=QUANTITY_BOOKED_SHOPIFY or AMOUNT_BOOKED_SHOPIFY!=amount_booked_ns)