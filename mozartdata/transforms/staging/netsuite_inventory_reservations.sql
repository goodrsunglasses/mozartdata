--CREATE OR REPLACE TABLE staging.netsuite_inventory_reservations
        --   COPY GRANTS  as
select * from netsuite.transaction where RECORDTYPE = 'orderreservation'