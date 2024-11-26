/*
Purpose: This table ingests and transforms netsuite.accoutingperiod into the EDW. This will be used for GL analysis

This is a copy with a CTE added for testing the pipeline root table.

*/

with root_table as (
  select
    *
  from
    test_schema.pipeline_root_table
)

select
  ap.id as accounting_period_id
  , date(ap.closedondate) as closed_on_date
  , date(ap.startdate) as period_start_date
  , date(ap.enddate) as period_end_date
  , ap.periodname as posting_period
  , case when ap.isinactive = 'F' then true else false end active_flag
  , case when ap.isposting = 'T' then true else false end is_posting_flag
  , case when ap.ISQUARTER = 'F' and ap.ISYEAR = 'F' then true else false end is_month_flag
  , case when ap.isquarter = 'T' then true else false end is_quarter_flag
  , case when ap.isyear = 'T' then true else false end is_year_flag
  , case when ap.closed = 'T' then true else false end closed_flag
  , case when ap.alllocked = 'T' then true else false end all_locked_flag
  , case when ap.ALLOWNONGLCHANGES = 'T' then true else false end allowing_gl_changes_flag
  , case when ap.aplocked = 'T' then true else false end ap_locked_flag
  , case when ap.arlocked = 'T' then true else false end ar_locked_flag
  , case when ap.isadjust = 'T' then true else false end is_adjust_flag
  , ap.PARENT as parent_accounting_period_id
  , parent.periodname as parent_posting_period
from
  netsuite.accountingperiod ap
left join
  netsuite.accountingperiod parent
  on ap.parent = parent.id
where
  ap._fivetran_deleted = false or ap._fivetran_deleted is null