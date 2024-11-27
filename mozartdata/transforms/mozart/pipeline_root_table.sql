/*
 This table is meant to serve as a kickoff table for the pipeline.

 It doesn't actually do anything, it just needs to run so the descendants will kick off.

 Add it into base tables using the following code:

with root_table as (
    select
        *
    from
        mozart.pipeline_root_table
)

and then add it as a root ancestor in the scheduling of the transform.
 */

select 1 as one