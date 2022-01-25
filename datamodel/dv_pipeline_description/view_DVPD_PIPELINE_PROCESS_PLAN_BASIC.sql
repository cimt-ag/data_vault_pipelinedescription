drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC as 

with leaf_field_group as (
select distinct
	dplapt.pipeline 
   , table_name 	
   , case when tracked_field_groups is not null then json_array_elements_text(tracked_field_groups) else '##all##' end as field_group
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline ddmtpp 
join dv_pipeline_description.dvpd_pipeline_leaf_and_process_table dplapt
	on dplapt.pipeline = ddmtpp.pipeline 
	and dplapt.leaf_table =ddmtpp.table_name 
)
,process_plan_basic as (
select distinct
	pipeline 
   ,field_group 
   , table_name 	
from  leaf_field_group
union 
select distinct
	dplapt.pipeline 
   ,field_group 
   , dplapt.table_to_process table_name 	
from  leaf_field_group lfg
join  dv_pipeline_description.dvpd_pipeline_leaf_and_process_table dplapt
    on 	dplapt.pipeline = lfg.pipeline 
	and dplapt.leaf_table =lfg.table_name
)
--,table_bk_variants as (
select
ppb.pipeline
,table_name
,ppb.field_group
,target_column_name
,field_name 
,sfm.field_group
from process_plan_basic ppb
join dv_pipeline_description.dvpd_source_field_mapping sfm on sfm.target_table=ppb.table_name
								and (sfm.field_group = ppb.field_group or sfm.field_group='##all##')
								and sfm.pipeline=ppb.pipeline
--group by 1,2,3
order by pipeline, table_name,ppb.field_group,target_column_name
;

												
-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC order by pipeline,field_group,table_name;										
