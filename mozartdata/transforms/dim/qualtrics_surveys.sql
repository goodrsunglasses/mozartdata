select distinct
        surv.id as survey_id_qualtrics
        , surv.survey_name
        , surv.survey_status
        , surv.option_survey_creation_date
        , surv.last_activated
        , surv.last_modified
        , count(s_resp.id) over (partition by s_resp.survey_id) as num_of_responses
        , round(avg(s_resp.duration_in_seconds) over (partition by s_resp.survey_id) / 60, 2) as avg_mins_to_complete
    from
        qualtrics.survey as surv
    left join
        qualtrics.survey_response as s_resp
        on surv.id = s_resp.survey_id