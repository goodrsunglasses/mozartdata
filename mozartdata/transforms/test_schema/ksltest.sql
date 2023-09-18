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
  section.name,
  task.name,
  task.parent_id
FROM
  asana.project_task proj
  LEFT OUTER JOIN asana.task task ON task.id = proj.task_id
  LEFT OUTER JOIN asana.task_section task_sect ON task_sect.task_id = task.id
  LEFT OUTER JOIN asana.section section ON section.id = task_sect.section_id