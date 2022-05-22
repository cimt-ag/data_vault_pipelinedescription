--drop view if exists dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_STAGE_TABLE_COLUMN as

with pipelines as (
select distinct epdtp.pipeline_name
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name 
where stereotype like 'xenc%'
)
select distinct 
	pipeline_name 
	,stage_column_name
	,column_type 
	,min(column_block) column_block
	,false is_meta
	,content_stage_hash_column
	,content_table_name
from  dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping
group by 1,2,3,5,6,7
union 
select
	pipeline_name 
	,dmcl.meta_column_name 
	,dmcl.meta_column_type 
	, 1
	,true is_meta
	,null content_stage_hash_column 
	,null content_table_name 
from pipelines 
join dv_pipeline_description.dvpd_meta_column_lookup dmcl on dmcl.stereotype ='_xenc_stg' ;



														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline,column_block ,stage_column_name 										