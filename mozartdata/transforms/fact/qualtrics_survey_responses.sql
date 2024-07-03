SELECT distinct
        s_r.survey_id as survey_id_qualtrics
        , s_r.id as response_id_qualtrics
        , q.id as question_id_qualtrics
        , q.data_export_tag AS question_num
        , q.question_type
        , q_r.sub_question_key
        , strip_html(q.question_text) as question_text
        , case
            when trim(strip_html(q_o.text)) = '' then q_r.label
            else trim(strip_html(q_o.text))
        end as user_response
    FROM
        qualtrics.survey_response as s_r
    inner join
        qualtrics.question as q
        on
            s_r.survey_id = q.survey_id
    inner join
        qualtrics.question_response as q_r
        on
            q.id = q_r.question_id
            and s_r.id = q_r.response_id
    cross join
        lateral split_to_table(q_r.value, ',') as split_values
    left join
        qualtrics.question_option as q_o
        on
            q.survey_id = q_o.survey_id
            and q.id = q_o.question_id
            and split_values.value = q_o.key
    WHERE
        q.question_type = 'MC'
        and trim(q_r.value) != ''
        and q_r.sub_question_key is null
        and q_r.question_option_key is null
        and q.question_text not like '%email address%'
        and q.question_text not like '%Zip Code%'
    union all
    SELECT
        s_r.survey_id as survey_id_qualtrics
        , s_r.id as response_id_qualtrics
        , q.id as question_id_qualtrics
        , q.data_export_tag AS question_num
        , q.question_type
        , q_r.sub_question_key
        , strip_html(q.question_text) as question_text
        , 'Other: ' || q_r.value as user_response
    FROM
        qualtrics.survey_response as s_r
    inner join
        qualtrics.question as q
        on
            s_r.survey_id = q.survey_id
    inner join
        qualtrics.question_response as q_r
        on
            q.id = q_r.question_id
            and s_r.id = q_r.response_id
    WHERE
        q.question_type = 'MC'
        and trim(q_r.value) != ''
        and q_r.sub_question_key is null
        and q_r.question_option_key is not null
        and q.question_text not like '%email address%'
        and q.question_text not like '%Zip Code%'
    union all
    select
        s_r.survey_id as survey_id_qualtrics
        , s_r.id as response_id_qualtrics
        , q.id as question_id_qualtrics
        , q.data_export_tag AS question_num
        , q.question_type
        , q_r.sub_question_key
        , strip_html(q_r.question) as question_text
        , q_r.label || ': ' || sq.text as user_response
    FROM
        qualtrics.survey_response as s_r
    inner join
        qualtrics.question as q
        on
            s_r.survey_id = q.survey_id
    inner join
        qualtrics.question_response as q_r
        on
            q.id = q_r.question_id
            and s_r.id = q_r.response_id
    left join
        qualtrics.sub_question as sq
        on
            q.id = sq.question_id
            and s_r.survey_id = sq.survey_id
            and q_r.sub_question_key = sq.key
    WHERE
        q.question_type = 'Matrix'
        and q_r.sub_question_key is not null
        and q_r.question_option_key is null
        and trim(q_r.value) != ''
        and q_r.label is not null
        and sq.text is not null
        and q.question_text not like '%email address%'
        and q.question_text not like '%Zip Code%'
    union all
    SELECT distinct
        s_r.survey_id as survey_id_qualtrics
        , s_r.id as response_id_qualtrics
        , q.id as question_id_qualtrics
        , q.data_export_tag AS question_num
        , q.question_type
        , q_r.sub_question_key
        , strip_html(q_r.question) as question_text
        , 'Other: ' || q_r.value as user_response
    FROM
        qualtrics.survey_response as s_r
    inner join
        qualtrics.question as q
        on
            s_r.survey_id = q.survey_id
    inner join
        qualtrics.question_response as q_r
        on
            q.id = q_r.question_id
            and s_r.id = q_r.response_id
    left join
        qualtrics.sub_question as sq
        on
            q.id = sq.question_id
            and s_r.survey_id = sq.survey_id
            and q_r.value = sq.key
    WHERE
        q.question_type = 'Matrix'
        and q_r.sub_question_key is not null
        and q_r.question_option_key is null
        and trim(q_r.value) != ''
        and q_r.label is null
        and sq.text is null
        and q.question_text not like '%email address%'
        and q.question_text not like '%Zip Code%'
    union all
    SELECT distinct
        s_r.survey_id as survey_id_qualtrics
        , s_r.id as response_id_qualtrics
        , q.id as question_id_qualtrics
        , q.data_export_tag AS question_num
        , q.question_type
        , q_r.sub_question_key
        , strip_html(q.question_text) as question_text
        , q_r.value as user_response
    FROM
        qualtrics.survey_response as s_r
    inner join
        qualtrics.question as q
        on
            s_r.survey_id = q.survey_id
    inner join
        qualtrics.question_response as q_r
        on
            q.id = q_r.question_id
            and s_r.id = q_r.response_id
    WHERE
        q.question_type != 'MC'
        and q.question_type != 'Matrix'
        and trim(q_r.value) != ''
        and q.question_text not like '%email address%'
        and q.question_text not like '%Zip Code%'
    ORDER BY
         survey_id_qualtrics asc
        , response_id_qualtrics asc
        , question_num asc