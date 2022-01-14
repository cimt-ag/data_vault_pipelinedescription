--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC cascade;

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

												
-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC order by pipeline,field_group,table_name;										
