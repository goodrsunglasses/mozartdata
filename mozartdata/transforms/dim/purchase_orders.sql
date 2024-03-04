WITH
  po_numbers AS ( --as of right now this is kinda redundant because NS is the only source of PO numbers but later as we add flexport, or SPS we'll add more sources
    SELECT DISTINCT
      order_id_edw
    FROM
      fact.purchase_order_line
  ),
  parents AS ( -- select just the parents from fact order line to join after, this is a cte because filtering the entire query for just parent = true ignores the ones that dont come from NS
    SELECT
      order_id_edw,
      transaction_id_ns,
      order_id_ns
    FROM
      fact.purchase_order_line
    WHERE
      is_parent = TRUE
  )
SELECT --Later we will def join this to flexport and other systems that house PO info, but as of right now its future proofing
  po_numbers.order_id_edw,
  parents.transaction_id_ns,
  parents.order_id_ns
FROM
  po_numbers
  LEFT OUTER JOIN parents ON parents.order_id_edw = po_numbers.order_id_edw