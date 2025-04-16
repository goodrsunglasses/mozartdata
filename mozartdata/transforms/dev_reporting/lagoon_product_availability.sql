WITH
  binventory AS (
    SELECT
      *
    FROM
      fact.netsuite_bin_inventory
  ),
  transfer_info AS (
    SELECT
      *
    FROM
      fact.transfer_order_item_detail
  )
select * from transfer_info