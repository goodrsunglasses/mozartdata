select distinct
        s_r.id as response_id_qualtrics
        , email_resp.value as email_address
        , s_r.ip_address
        , s_r.recorded_date
        , max(s_r.location_latitude) over (
            partition by
                email_resp.value
                , s_r.ip_address
            order by
                s_r.recorded_date desc
        ) latitude
        , max(s_r.location_longitude) over (
            partition by
                email_resp.value
                , s_r.ip_address
            order by
                s_r.recorded_date desc
        ) longitude
        , zip_resp.value as zip_code
        , zip_type_resp.label as zip_code_type
    from
        qualtrics.survey_response as s_r
    left join
        qualtrics.question_response as email_resp
        on
            s_r.id = email_resp.response_id
            and email_resp.question like '%email%'
    left join
        qualtrics.question_response as zip_resp
        on
            s_r.id = zip_resp.response_id
            and zip_resp.question like '%Zip Code%'
            and zip_resp.label is null
    left join
        qualtrics.question_response as zip_type_resp
        on
            s_r.id = zip_type_resp.response_id
            and zip_type_resp.question like '%Zip Code%'
            and zip_type_resp.label is not null