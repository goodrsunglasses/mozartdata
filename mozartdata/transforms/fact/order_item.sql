WITH
  detector AS (
    SELECT DISTINCT
      order_id_edw order_id,
      MAX(
        CASE
          WHEN recordtype IN ('invoice', 'cashsale') THEN 1
          ELSE 0
        END
      ) OVER (
        PARTITION BY
          order_id_edw,
          item
      ) AS has_invoice_cashsale
    FROM
      fact.order_item_detail
  )
SELECT DISTINCT
  order_id_edw,
  item,
  plain_name,
  SUM(
    CASE
      WHEN recordtype IN ('salesorder') THEN full_quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS quantity_booked,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale') THEN full_quantity
      WHEN recordtype = 'salesorder'
      AND has_invoice_cashsale = 0 THEN full_quantity
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
      WHEN recordtype IN ('cashrefund') THEN full_quantity
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS quantity_refunded,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale', 'cashrefund') THEN rate
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS rate_items,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale', 'cashrefund') THEN netamount
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS amount_items,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale') THEN costestimate
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS costestimate,
  SUM(
    CASE
      WHEN recordtype IN ('invoice', 'cashsale') THEN estgrossprofit
      ELSE 0
    END
  ) over (
    PARTITION BY
      order_id_edw,
      item
  ) AS estgrossprofit,
  MD5(CONCAT(order_id_edw, '_', item)) AS order_item_id
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN detector ON detector.order_id = detail.order_id_edw