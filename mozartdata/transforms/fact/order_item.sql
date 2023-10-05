SELECT DISTINCT
  order_id_edw,
  item,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale') THEN full_quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS quantity_sold,
  SUM(
    CASE
      WHEN recordtype IN ('itemfulfillment') THEN full_quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS quantity_fulfilled,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale') THEN product_rate
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS rate_items
  
FROM
  fact.order_item_detail
WHERE
  order_id_edw = 'G2534171'