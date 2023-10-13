WITH
  booked AS (
    SELECT
      order_id_edw,
      item,
      plain_name,
      CONCAT(order_id_edw, '_', item) AS order_item_id,
      SUM(full_quantity) AS quantity_booked,
      SUM(rate) AS rate_booked,
      SUM(netamount) AS amount_booked
    FROM
      fact.order_item_detail
    WHERE
      recordtype = 'salesorder'
    GROUP BY
      order_id_edw,
      item,
      plain_name,
      order_item_id
  ),
  sold AS (
    SELECT
      order_id_edw,
      item,
      plain_name,
      CONCAT(order_id_edw, '_', item) AS order_item_id,
      SUM(full_quantity) AS quantity_sold,
      SUM(rate) AS rate_sold,
      SUM(netamount) AS amount_sold,
      sum(estgrossprofit) as estgrossprofit,
      sum(abs(costestimate)) as costestimate
    FROM
      fact.order_item_detail
    WHERE
      recordtype IN ('cashsale', 'invoice')
    GROUP BY
      order_id_edw,
      item,
      plain_name,
      order_item_id
  ),
  fulfilled AS (
    SELECT
      order_id_edw,
      item,
      plain_name,
      CONCAT(order_id_edw, '_', item) AS order_item_id,
      SUM(full_quantity) AS quantity_fulfilled,
      SUM(rate) AS rate_fulfilled,
      SUM(netamount) AS amount_fulfilled
    FROM
      fact.order_item_detail
    WHERE
      recordtype = 'itemfulfillment'
    GROUP BY
      order_id_edw,
      item,
      plain_name,
      order_item_id
  ),
  refunded AS (
    SELECT
      order_id_edw,
      item,
      plain_name,
      CONCAT(order_id_edw, '_', item) AS order_item_id,
      SUM(full_quantity) AS quantity_refunded,
      SUM(rate) AS rate_refunded,
      SUM(abs(netamount)) AS amount_refunded
    FROM
      fact.order_item_detail
    WHERE
      recordtype = 'cashrefund'
    GROUP BY
      order_id_edw,
      item,
      plain_name,
      order_item_id
  )
SELECT DISTINCT
  detail.order_id_edw,
  detail.item,
  detail.plain_name,
  CONCAT(detail.order_id_edw, '_', detail.item) AS order_item_id,
  quantity_booked,
  quantity_sold,
  quantity_fulfilled,
  quantity_refunded,
  rate_booked,
  rate_sold,
  rate_fulfilled,
  rate_refunded,
  amount_booked,
  amount_sold,
  amount_fulfilled,
  amount_refunded,
  sold.estgrossprofit,
  sold.costestimate
FROM
  fact.order_item_detail detail
  LEFT OUTER JOIN booked ON (
    booked.order_id_edw = detail.order_id_edw
    AND booked.item = detail.item
  )
  LEFT OUTER JOIN sold ON (
    sold.order_id_edw = detail.order_id_edw
    AND sold.item = detail.item
  )
  LEFT OUTER JOIN fulfilled ON (
    fulfilled.order_id_edw = detail.order_id_edw
    AND fulfilled.item = detail.item
  )
  LEFT OUTER JOIN refunded ON (
    refunded.order_id_edw = detail.order_id_edw
    AND refunded.item = detail.item
  )
WHERE
  detail.order_id_edw IN ('G1017793', 'G1004173')
ORDER BY
  detail.order_id_edw