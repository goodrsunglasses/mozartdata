SELECT distinct
  section.name,
  task.name,
  task.parent_id

FROM
  asana.project_task proj
  LEFT OUTER JOIN asana.task task ON task.id = proj.task_id
  left outer join asana.task_section task_sect on task_sect.task_id = task.id
  left outer join asana.section section on section.id =task_sect.section_id
WHERE
  proj.project_id = 1205095605823493