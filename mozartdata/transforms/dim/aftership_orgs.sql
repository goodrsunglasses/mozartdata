/*
    Table name:
        dim.aftership_orgs
    Created:
        3-26-2025
    Purpose:
        Shows distinct aftership org ids and names as defined in the staging.aftership_rmas table.
    Schema:
        org_id_aftership: id of the organization, self defined in the staging.aftership_rmas table by data team
            Primary Key
        org_name_aftership: name of organization as it shows on the aftership front end, defined by creators of the org
 */
 select distinct
    org_id_aftership
    , org_name_aftership
 from
    staging.aftership_rmas