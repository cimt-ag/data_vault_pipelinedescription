drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN as 

with dv_table_column_count as (
select distinct
    table_name 	
   , count(1) data_column_count
from dv_pipeline_description.dvpd_dv_model_column ddmtpp
where dv_column_class not in ('meta','key','parent_key','diff_hash')
group by table_name
)
--,target_process_block 

select distinct 
	pipeline 
	,process_block 
	,target_table 
from dv_pipeline_description.dvpd_source_field_mapping

--,field_Mappings_per_process_block
--,table_columns_per_pipeline
select
	pipeline 
	,tpp.table_name 
	,column_name
	, json_array_elements_text(tracked_field_groups) field_group
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tpp
join dv_pipeline_description.dvpd_dv_model_column dvcol on dvcol.table_name = tpp.table_name 
where dvcol.dv_column_class not in('meta')
union 
select
	pipeline 
	,tpp.table_name 
	,column_name
	, '##all##' field_group 
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline tpp
join dv_pipeline_description.dvpd_dv_model_column dvcol on dvcol.table_name = tpp.table_name 
where dvcol.dv_column_class not in('meta') and tracked_field_groups is null
order by 1,2,3
														

,field_group_target_column_count as (
select distinct
	pipeline
   ,field_group 
   ,target_table
   ,count(1) field_count
from dv_pipeline_description.dvpd_pipeline_column_mapping_with_field_group_extention
where field_name is not null
group by pipeline,field_group,target_table 
)
select 
 pipeline
, field_group
, dtcc.table_name
, dtcc.data_column_count
, fgtcc.field_count
,  dtcc.data_column_count-fgtcc.field_count
from dv_table_column_count dtcc
join field_group_target_column_count fgtcc on fgtcc.target_table = dtcc.table_name


-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC order by pipeline,field_group,table_name;										
