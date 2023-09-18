WITH
  recursive_tasks AS (
    SELECT
      task.id,
      task.name,
      task.parent_id,
      t_section.section_id
    FROM
      asana.task task
      LEFT OUTER JOIN asana.project_task proj ON task.id = proj.task_id
      LEFT OUTER JOIN asana.task_section t_section ON t_section.task_id = task.id
    WHERE
      proj.project_id = 1205095605823493
    UNION ALL
    SELECT
      task.id,
      task.name,
      task.parent_id,
      recursive_tasks.section_id
    FROM
      asana.task task
      JOIN recursive_tasks ON task.parent_id = recursive_tasks.id
  )
SELECT
  section.name as section_name,
  recursive_tasks.name,
  user.name as assigned_to
FROM
  recursive_tasks
  LEFT OUTER JOIN asana.section section ON section.id = recursive_tasks.section_id
  left outer join asana.task task on task.id=recursive_tasks.id
  left outer join asana.user user on user.id=task.assignee_id
where section.name='This Sprint'