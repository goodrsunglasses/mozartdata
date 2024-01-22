SELECT DISTINCT
  fulfillment_id_edw,
  order_id_edw,
  source,
  carrier,
  carrier_service,
  shipdate,
  shipment_cost,
  voided,
  country,
  state,
  city,
  shipment_id,
  SUM(quantity) over (
    PARTITION BY
      fulfillment_id_edw
  ) AS total_quantity
FROM
  fact.fulfillment_item_detail