--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_ALL;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_ALL as (

select
	pipeline
	,'01 DV Model Columns' issue_class
	,rank() over (order by schema_name ,table_name,column_block,column_name,atmtst_issue_message ) issue_order
	,coalesce(schema_name || '.','') ||
	 coalesce(table_name,'#missing#') ||' | ' ||
	 coalesce(column_block,-1) || ' | ' ||
	 coalesce(dv_column_class,'#missing#') || ' | ' ||
	 coalesce(column_name,'#missing#') || ' | ' ||
	 coalesce(column_type,'#missing#') result_string
	,atmtst_issue_message
from
	dv_pipeline_description.dvpd_atmtst_issue_dv_model_column
union
select
	 pipeline_name
	,'02 Process Column Mapping' issue_class
	,rank() over (order by table_name,process_block,column_name ) issue_order
	,	coalesce (table_name,'#missing#') || ' | ' ||
		coalesce (process_block,'#missing#') || ' | ' ||
		coalesce (column_name,'#missing#') || ' | ' ||
		coalesce (stage_column_name,'#missing#') || ' | ' ||
		coalesce (field_name,'') result_string
	,atmtst_issue_message
from
	dv_pipeline_description.dvpd_atmtst_issue_process_column_mapping
union
select
	pipeline_name
	,'03 Hash Input fields' issue_class
	,rank() over (order by process_block,stage_column_name,field_name ) issue_order
	,coalesce(process_block,'#missing#') || ' | ' ||
	 coalesce(stage_column_name,'#missing#') || ' | ' ||
	 coalesce(field_name,'#missing#') || ' | ' ||
	 coalesce(prio_in_key_hash,-1) || ' | ' ||
	 coalesce(prio_in_diff_hash,-1) result_string 
	 ,atmtst_issue_message
from
	dv_pipeline_description.dvpd_atmtst_issue_stage_hash_input_field
union
select
	pipeline
	,'04 Stage Table Columns' issue_class
	,rank() over (order by column_block,stage_column_name ) issue_order
	,coalesce(stage_column_name,'#missing#') || ' | ' ||
	 coalesce(column_type,'#missing#') || ' | ' ||
	 coalesce(column_block,-1) || ' | ' ||
	 coalesce(field_name,'#missing#') || ' | ' ||
	 coalesce(field_type,'#missing#') || ' | ' ||
	 case when encrypt then 'true'
	 	  when not encrypt then 'false' 
	 	  else '#missing#' end  as result_string
	,atmtst_issue_message
from
	dv_pipeline_description.dvpd_atmtst_issue_stage_table_column
order by pipeline,issue_class ,issue_order 

);
 
comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_ALL IS
	'All issues currently open';
 
-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_ALL;
