drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN as 

with dv_table_column_count as (
select distinct
    table_name 	
   , count(1)
from dv_pipeline_description.dvpd_dv_model_column ddmtpp
where dv_column_class not in ('meta')
group by table_name
)
,field_group_target_column_count as (

select distinct
	pipeline
   ,field_group 
   ,target_table
   ,count(1)
from dv_pipeline_description.dvpd_pipeline_column_mapping_with_field_group_extention
group by pipeline,field_group,target_table 

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC order by pipeline,field_group,table_name;										
