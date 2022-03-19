--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_STAGE_TABLE_COLUMN as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_stage_table_column
)
,result_data as (
select 
 pstc.pipeline
 ,stage_column_name
 ,column_type
 ,column_block
 ,coalesce(field_name,'') field_name
 ,coalesce(field_type,'')  field_type
 ,coalesce(pstc.is_encrypted ,false) encrypt
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.dvpd_pipeline_stage_table_column pstc on pstc.pipeline  =pwad.pipeline_name 
	   													and not pstc.is_meta 			   													
)   													
, reference_data as ( 
select 
 pipeline_name  
 ,stage_column_name
 ,column_type
 ,column_block
 ,coalesce(field_name,'') field_name 
 ,coalesce(field_type,'') field_type
 ,encrypt
from dv_pipeline_description.dvpd_atmtst_ref_stage_table_column
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
	'Shows all issues from automated testing of stage_table_columns, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


