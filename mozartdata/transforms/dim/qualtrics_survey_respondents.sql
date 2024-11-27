/*
Purpose: to show the data associated with respondents to qualtrics surveys.
One row per respondent, which breaks down to one user per response.

Base table: CTE root_table is used to get root table reference for scheduling in mozart.
If no longer a base table, then remove CTE root_table.
*/

with root_table as (
    select
      *
    from
      mozart.pipeline_root_table
)
select distinct
        s_r.id as response_id_qualtrics
        , email_resp.value as email_address
        , s_r.ip_address
        , s_r.recorded_date as recorded_date_timestamp
        , date(s_r.recorded_date) as recorded_date
        , s_r.location_latitude as latitude
        , s_r.location_longitude as longitude
        , zip_resp.value as zip_code
        , zip_type_resp.label as zip_code_type
    from
        qualtrics.survey_response as s_r
    left join
        qualtrics.question_response as email_resp
        on
            s_r.id = email_resp.response_id
            and lower(email_resp.question) like '%email%'
    left join
        qualtrics.question_response as zip_resp
        on
            s_r.id = zip_resp.response_id
            and lower(zip_resp.question) like '%zip code%'
            and zip_resp.label is null
    left join
        qualtrics.question_response as zip_type_resp
        on
            s_r.id = zip_type_resp.response_id
            and lower(zip_type_resp.question) like '%zip code%'
            and zip_type_resp.label is not null