--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN cascade;

-- This version is limited to work only without field groups and hierarchical links

create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN as



with pipelines AS(
select distinct pipeline 
from dv_pipeline_description.dvpd_source_field
)
select distinct 
	plap.pipeline 
	,coalesce (sfm.field_name,mc.column_name )   stage_column_name
	,mc.column_type 
	,min(mc.column_block) column_block
	,sfm.field_name 
	,sfm.field_type 
	,coalesce(sfm.is_encrypted ,false) encrypt
	,false is_meta
from dv_pipeline_description.dvpd_pipeline_leaf_and_process_table plap 
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name = plap.table_to_process 
													 and mc.dv_column_class not in ('meta')
left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm on sfm.target_table = plap.table_to_process 	
													  and sfm.target_column_name =mc.column_name
group by 1,2,3,5,6,7
union 
select
	pipeline 
	,dmcl.meta_column_name 
	,dmcl.meta_column_type 
	, 1
	,null 
	,null
	,false
	,true is_meta
from pipelines 
join dv_pipeline_description.dvpd_meta_column_lookup dmcl on dmcl.stereotype ='_stg' ;


														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline,column_block ,stage_column_name 										