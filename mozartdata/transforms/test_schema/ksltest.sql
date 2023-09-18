WITH
  recursive_tasks AS (
    SELECT
      task.id,
      task.name,
      task.parent_id
    FROM
  asana.task task
      LEFT OUTER JOIN  asana.project_task proj ON task.id = proj.task_id
    WHERE
      proj.project_id = 1205095605823493
    UNION ALL
      SELECT
      task.id,
      task.name,
      task.parent_id
    FROM
       asana.task task 
    join recursive_tasks on task.parent_id = recursive_tasks.id
  
  )
SELECT
  section.name,
  recursive_tasks.name
FROM
  recursive_tasks
left outer join asana.task_section t_section on t_section.task_id = recursive_tasks.id
left outer join asana.section section on section.id = t_section.section_id