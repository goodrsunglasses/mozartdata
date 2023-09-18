WITH
  main_proj_tasks AS (
    SELECT
      task_id,
      task.name
    FROM
      asana.project_task proj
      LEFT OUTER JOIN asana.task task ON task.id = proj.task_id
    WHERE
      proj.project_id = 1205095605823493
  )
SELECT DISTINCT
  main_proj_tasks.name,
  task.name
FROM
main_proj_tasks
left outer join asana.task task on task.parent_id = main_proj_tasks.task_id