SELECT DISTINCT --added a distinct to handle NS information potentially being incorrect
                fulfillment_id_edw,
                order_id_edw,
                product_id_edw,
                quantity
FROM fact.fulfillment_item_detail