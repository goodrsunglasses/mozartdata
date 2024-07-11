select
        survey.survey_name
        , respondent.email_address
        , respondent.ip_address
        , respondent.recorded_date
        , respondent.zip_code
        , respondent.zip_code_type
        , respondent.latitude
        , respondent.longitude
        , response.question_num
        , response.question_type
        , response.question_text
        , response.user_response
    from
        fact.qualtrics_survey_responses as response
    inner join
        dim.qualtrics_surveys as survey
        on
            response.survey_id_qualtrics = survey.survey_id_qualtrics
    inner join
        dim.qualtrics_survey_respondents as respondent
        on
            response.response_id_qualtrics = respondent.response_id_qualtrics