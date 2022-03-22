--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_stage_hash_input_field
)
,result_data as (
select 
	pipeline_name 
	,process_block
	,stage_column_name
	,field_name
	,prio_in_key_hash
	,prio_in_diff_hash
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.dvpd_pipeline_stage_hash_input_field pshif on pshif.pipeline  =pwad.pipeline_name 
)   													
, reference_data as ( 
select 
	pipeline_name 
	,process_block
	,stage_column_name
	,field_name
	,prio_in_key_hash
	,prio_in_diff_hash
from dv_pipeline_description.dvpd_atmtst_ref_stage_hash_input_field
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


comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD IS
	'Shows all issues from automated testing of stage_hash_input_field, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_HASH_INPUT_FIELD ddmcc  order by 1,2,3,4,5;


