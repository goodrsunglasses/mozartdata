SELECT
  main_query.*,
  CASE
    WHEN quantity_fulfilled_ns < quantity_on_salesorder
    AND quantity_backordered = 0 and quantity_shipped_stord = quantity_on_salesorder THEN TRUE
    ELSE FALSE
  END AS fulfillable,
  CASE
    WHEN quantity_backordered > 0
    AND quantity_shipped_stord > 0 THEN TRUE
    ELSE FALSE
  END AS backordered_but_shipped
FROM
  (
    WITH
      stord_info AS (
        SELECT
          SPLIT_PART(fulfillment_id_edw, '_', 2) AS tracking,
          order_id_edw,
          shipment_id,
          warehouse_location,
          date(shipdate) shipdate,
          voided,
          sku,
          product_name,
          quantity
        FROM
          fact.fulfillment_item_detail
        WHERE
          source = 'Stord'
      ),
      booked_info AS (
        SELECT
          detail.order_id_ns,
          detail.transaction_id_ns,
          detail.transaction_created_date_pst,
          detail.full_status,
          prod.sku,
          detail.plain_name,
          detail.total_quantity,
          detail.quantity_backordered,
          detail.location,
          loc.name
        FROM
          fact.order_item_detail detail
          LEFT OUTER JOIN dim.product prod ON prod.item_id_ns = detail.item_id_ns
          LEFT OUTER JOIN dim.location loc ON loc.location_id_ns = detail.location
        WHERE
          record_type = 'salesorder'
          AND full_status NOT IN (
            'Sales Order : Billed',
            'Sales Order : Pending Billing',
            'Sales Order : Closed',
            'Sales Order : Cancelled'
          )
          AND plain_name NOT IN ('Shipping', 'Tax', 'Discount')
      )
    SELECT
      booked_info.order_id_ns AS order_number,
      booked_info.transaction_id_ns AS netsuite_transaction_id,
      booked_info.transaction_created_date_pst AS salesorder_date,
      booked_info.full_status AS salesorder_status,
      booked_info.sku,
      booked_info.plain_name AS display_name,
      booked_info.total_quantity AS quantity_on_salesorder,
      quantity_backordered,
      CASE
        WHEN item.quantity_fulfilled IS NULL THEN 0
        ELSE item.quantity_fulfilled
      END AS quantity_fulfilled_ns,
      name AS location_name_netsuite,
      CASE
        WHEN sum(stord_info.quantity) IS NULL THEN 0
        ELSE sum(stord_info.quantity)
      END AS quantity_shipped_stord
    FROM
      booked_info
      LEFT OUTER JOIN stord_info ON (
        stord_info.sku = booked_info.sku
        AND booked_info.order_id_ns = stord_info.order_id_edw
      )
      LEFT OUTER JOIN fact.order_item item ON (
        item.sku = booked_info.sku
        AND booked_info.order_id_ns = item.order_id_ns
      )
    WHERE
      location_name_netsuite IN ('Stord LAS', 'Stord ATL', 'Stord HOLD')
    GROUP BY
      booked_info.order_id_ns,
      booked_info.transaction_id_ns,
      booked_info.transaction_created_date_pst,
      booked_info.full_status,
      booked_info.sku,
      booked_info.plain_name,
      booked_info.total_quantity,
      quantity_backordered,
      quantity_fulfilled,
      name
    ORDER BY
      booked_info.order_id_ns
  ) main_query