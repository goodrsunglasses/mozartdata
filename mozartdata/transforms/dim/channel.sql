/*
Purpose: to show each sales channel used for reporting. Is one row per channel_id_edw.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with
    root_table as (
                      select
                          *
                      from
                          mozart.pipeline_root_table
    )
SELECT
  id AS channel_id_edw,
  id AS channel_id_ns,
  name,
  CASE
    WHEN name IN (
      'Specialty',
      'Key Account',
      'Key Accounts', 
      'Global',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'B2B'
    WHEN name IN (
      'Goodr.com',
      'Amazon',
      'Amazon Canada',
      'Amazon Prime',
      'Cabana',
      'Goodr.com CAN',
      'Prescription',
      'goodr.ca'
    ) THEN 'D2C'
    WHEN name IN (
      'Goodrwill.com',
      'Customer Service CAN',
      'Marketing',
      'Co-Brand',
      'Donations',
      'Goodrstock Giveaways',
      'Content Giveaways',
      'Customer Service'
    ) THEN 'INDIRECT'
  END AS customer_category,
  CASE
    WHEN name IN (
      'Specialty',
      'Key Account',
      'Key Accounts',
      'Key Account CAN',
      'Specialty CAN'
    ) THEN 'Wholesale'
    WHEN name IN ('Goodr.com', 'Goodr.com CAN','goodr.ca') THEN 'Digital'
    WHEN name IN ('Amazon', 'Amazon Prime','Prescription','Amazon Canada') THEN 'Partner'
    WHEN name IN ('Cabana') THEN 'Retail'
    WHEN name IN ('Global') THEN 'Distribution'
    WHEN name IN (
      'Goodrwill.com',
      'Customer Service CAN',
      'Marketing',
      'Co-Brand',
      'Donations',
      'Goodrstock Giveaways',
      'Content Giveaways',
      'Customer Service'
    ) THEN 'Indirect'
  END AS model,
  CASE WHEN name IN  ('goodr.ca','Specialty CAN','Customer Service CAN','Key Account CAN') then 3 else 1 end as currency_id_ns,
  CASE WHEN name IN  ('goodr.ca','Specialty CAN','Customer Service CAN','Key Account CAN') then 'CAD' else 'USD' end as currency_abbreviation
FROM
  netsuite.customrecord_cseg7 channel
ORDER BY
  name