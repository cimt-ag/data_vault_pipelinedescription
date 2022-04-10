--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_PROCESS_COLUMN_MAPPING as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_process_column_mapping
)
,result_data as (
select 
 pwad.pipeline_name 
	,table_name 
	,process_block 
	,column_name 
	,stage_column_name
	,field_name
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmmc on ppstdmmc.pipeline  =pwad.pipeline_name 
	   													and dv_column_class not in ('meta') 			   													
)   													
, reference_data as ( 
select 
 pipeline_name  
,table_name 
	,process_block 
	,column_name 
	,stage_column_name
	,field_name
from dv_pipeline_description.dvpd_atmtst_ref_process_column_mapping darpcm 
)
,not_in_reference as (
select * from result_data 
except 
select * from reference_data 
)
,only_in_reference as (
select * from reference_data
except 
select * from result_data 
)
select *,'not in reference' atmtst_issue_message
from not_in_reference 
union
select *,'only in reference' atmtst_issue_message
from only_in_reference 

);


comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN IS
	'Shows all issues from automated testing of process_column_mapping, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


