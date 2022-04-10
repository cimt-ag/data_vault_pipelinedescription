--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN as

with pipelines AS(
select distinct pipeline_name 
from dv_pipeline_description.dvpd_pipeline_target_table
)
select distinct 
	pipeline_name 
	,stage_column_name
	,column_type 
	,min(column_block) column_block
	,false is_meta
	,field_name
	,field_type
	,needs_encryption
from  dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping
group by 1,2,3,5,6,7,8
union 
select
	pipeline_name 
	,dmcl.meta_column_name 
	,dmcl.meta_column_type 
	, 1
	,true is_meta
	,null field_name 
	,null field_type 
	,false needs_encryption 
from pipelines 
join dv_pipeline_description.dvpd_meta_column_lookup dmcl on dmcl.stereotype ='_stg' ;


														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline,column_block ,stage_column_name 										