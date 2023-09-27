WITH RECURSIVE
  recursive_tasks AS (
    SELECT
      task.id,
      task.name,
      task.parent_id,
      t_section.section_id,
      NULL AS immediate_parent_name
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
      recursive_tasks.section_id,
      recursive_tasks.name AS immediate_parent_name
    FROM
      asana.task task
      JOIN recursive_tasks ON task.parent_id = recursive_tasks.id
  )
SELECT
  section.name AS section_name,
  immediate_parent_name AS parent_name,
  recursive_tasks.name task_name,
  user.name AS assigned_to,
  CASE
    WHEN task.completed THEN 'Completed'
    ELSE 'In Progress'
  END AS status
FROM
  recursive_tasks
  LEFT OUTER JOIN asana.section section ON section.id = recursive_tasks.section_id
  LEFT OUTER JOIN asana.task task ON task.id = recursive_tasks.id
  LEFT OUTER JOIN asana.user user ON user.id = task.assignee_id
WHERE
  section.name = '1️⃣This Sprint'
order by assigned_to asc