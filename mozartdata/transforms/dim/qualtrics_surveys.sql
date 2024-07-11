select distinct
        surv.id as survey_id_qualtrics
        , surv.survey_name
        , surv.survey_status
        , surv.option_survey_creation_date as survey_creation_timestamp
        , date(surv.option_survey_creation_date) as survey_creation_date
        , surv.last_activated as last_acivated_timestamp
        , date(surv.last_activated) as last_activated_date
        , surv.last_modified as last_modified_timestamp
        , date(surv.last_modified) as last_modified_date
        , count(s_resp.id) over (partition by s_resp.survey_id) as num_of_responses
        , round(avg(s_resp.duration_in_seconds) over (partition by s_resp.survey_id) / 60, 2) as avg_mins_to_complete
        , round(median(s_resp.duration_in_seconds) over (partition by s_resp.survey_id) / 60, 2) as median_mins_to_complete
    from
        qualtrics.survey as surv
    left join
        qualtrics.survey_response as s_resp
        on surv.id = s_resp.survey_id