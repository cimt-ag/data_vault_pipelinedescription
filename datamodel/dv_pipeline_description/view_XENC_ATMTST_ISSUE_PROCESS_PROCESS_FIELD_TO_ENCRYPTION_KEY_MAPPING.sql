--drop view if exists dv_pipeline_description.XENC_ATMTST_ISSUE_PROCESS_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING;
create or replace view dv_pipeline_description.XENC_ATMTST_ISSUE_PROCESS_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_process_column_mapping
)
,result_data as (
select 
    pwad.pipeline_name 
	,process_block 
	,field_name 
	,content_stage_column_name 
	,encryption_key_stage_column_name
	,stage_map_rank 
from pipelines_with_atmtst_data pwad								
join dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING t1
	on pwad.pipeline_name =t1.pipeline_name 
)   													
, reference_data as ( 
select 
    pipeline_name 
	,process_block 
	,field_name 
	,content_stage_column_name 
	,encryption_key_stage_column_name
	,stage_map_rank 
from dv_pipeline_description.XENC_ATMTST_REF_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING darpcm 
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


comment on view dv_pipeline_description.XENC_ATMTST_ISSUE_PROCESS_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING IS
	'Shows all issues from automated testing of field to encryption key mapping';

-- select * from dv_pipeline_description.XENC_ATMTST_ISSUE_PROCESS_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING ddmcc  order by 1,2,3,4,5;


