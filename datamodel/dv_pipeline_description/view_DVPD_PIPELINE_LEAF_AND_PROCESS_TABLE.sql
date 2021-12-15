--drop view if exists dv_pipeline_description.DVPD_PIPELINE_LEAF_AND_PROCESS_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_LEAF_AND_PROCESS_TABLE as 
with leaf_tables_per_pipeline as (
	select distinct pipeline,ddmt.table_name 
	from dv_pipeline_description.dvpd_dv_model_table_per_pipeline ddmt   
	where ddmt.stereotype in('sat','msat','esat') or ddmt.is_link_without_sat 
)
-- leaf table itself
Select 
	pipeline 
	,table_name leaf_table
	,table_name table_to_process
from leaf_tables_per_pipeline
union
-- direct parent
select 
	pipeline 
	,lt.table_name leaf_table_name
	,mt.satellite_parent_table table_to_process
from leaf_tables_per_pipeline lt
join dv_pipeline_description.dvpd_dv_model_table mt on mt.table_name = lt.table_name
-- link parent
union
select 
	pipeline 
	,lt.table_name leaf_table_name
	,ddmlp.parent_table_name table_to_process
from leaf_tables_per_pipeline lt
join dv_pipeline_description.dvpd_dv_model_table mt on mt.table_name = lt.table_name
join dv_pipeline_description.dvpd_dv_model_link_parent ddmlp on ddmlp.table_name = mt.satellite_parent_table;

comment on view dv_pipeline_description.DVPD_PIPELINE_LEAF_AND_PROCESS_TABLE 
is 'Lists all tables to process for every leaf table of a pipeline';

-- select * from dv_pipeline_description.DVPD_PIPELINE_LEAF_AND_PROCESS_TABLE;