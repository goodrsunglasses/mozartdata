SELECT DISTINCT
  line.fulfillment_id_edw,
  line.order_id_edw,
  line.source,
  line.carrier,
  line.carrier_service,
  line.shipdate,
  line.shipment_cost,
  line.voided,
  line.country,
  line.state,
  line.city,
  line.shipment_id AS source_shipment_id,
  SUM(quantity) over (
    PARTITION BY
      item.fulfillment_id_edw
  ) AS total_quantity
FROM
  fact.fulfillment_line line
  LEFT OUTER JOIN fact.fulfillment_item item ON item.fulfillment_id_edw = line.fulfillment_id_edw