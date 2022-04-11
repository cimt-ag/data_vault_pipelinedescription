--drop view if exists dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN as (
 
with 
pipelines_with_atmtst_data as (
select distinct pipeline_name 
from dv_pipeline_description.dvpd_atmtst_ref_dv_model_column
)
,result_data as (
select 
 pwad.pipeline_name 
 ,pdt.schema_name 
 ,pdc.table_name 
 ,pdc.column_block 
 ,pdc.dv_column_class 
 ,pdc.column_name 
 ,pdc.column_type 
from  pipelines_with_atmtst_data pwad
join dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN pdc  on  pdc.pipeline_name =pwad.pipeline_name 
   													and pdc.dv_column_class  <> 'meta'	
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.pipeline_name =  pwad.pipeline_name 
													and pdt.table_name = pdc.table_name 
)   													
, reference_data as ( 
select 
 pipeline_name 
 ,schema_name
 ,table_name 
 ,column_block 
 ,dv_column_class 
 ,column_name 
 ,column_type 
from dv_pipeline_description.dvpd_atmtst_ref_dv_model_column
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

comment on view dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN IS
	'Shows all issues from automated testing of dv_model_column, for pipelines, where reference data is available';

-- select * from dv_pipeline_description.DVPD_ATMTST_ISSUE_DV_MODEL_COLUMN ddmcc  order by 1,2,3,4,5;


