--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN as

with pipeline_model_profile AS (
select distinct pipeline_name ,model_profile_name
from dv_pipeline_description.dvpd_pipeline_dv_table
)
, pipelines AS(
select distinct pp.pipeline_name ,model_profile_name
from dv_pipeline_description.dvpd_pipeline_properties_raw pp
left join pipeline_model_profile pmp on pmp.pipeline_name= pp.pipeline_name 
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
	pp.pipeline_name 
	,mpmcl.meta_column_name 
	,mpmcl.meta_column_type 
	, 1
	,true is_meta
	,null field_name 
	,null field_type 
	,false needs_encryption 
from pipelines pp
left join dv_pipeline_description.dvpd_model_profile_meta_column_lookup mpmcl 
										on mpmcl.model_profile_name = pp.model_profile_name 
										and mpmcl.stereotype ='_stg' ;
														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline,column_block ,stage_column_name 										