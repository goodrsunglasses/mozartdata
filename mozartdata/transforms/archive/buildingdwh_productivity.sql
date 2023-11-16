SELECT
    COUNT(DISTINCT CASE WHEN created_at >= DATEADD(DAY, -7, CURRENT_TIMESTAMP()) THEN task_name END) AS distinct_tasks_created_last_week,
    COUNT(DISTINCT CASE WHEN completed_at >= DATEADD(DAY, -7, CURRENT_TIMESTAMP()) THEN task_name END) AS distinct_tasks_completed_last_week
FROM
    archive.buildingdwh_productivity_backend
WHERE
    (created_at >= DATEADD(DAY, -7, CURRENT_TIMESTAMP()) OR completed_at >= DATEADD(DAY, -7, CURRENT_TIMESTAMP()));