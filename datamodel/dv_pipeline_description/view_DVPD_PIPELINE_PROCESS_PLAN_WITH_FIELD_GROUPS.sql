drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_WITH_FIELD_GROUPS cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_WITH_FIELD_GROUPS as 

with hash_input_columns as (
select
	 hash_target.table_name 
	,hash_target.column_name hash_column
	,content_key.table_name content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
where hash_target.dv_column_class in ('key')
union all
select 
	 link_parent.table_name 
	,link_parent.parent_hub_key_column_name 
	,content_key.table_name  content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_link_parent link_parent
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =link_parent.parent_table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
union all
select
	 hash_target.table_name 
	,hash_target.column_name hash_column
	,content_key.table_name content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('content')
where hash_target.dv_column_class in ('diff_hash')
order by 1,2,3,4
)
, unusable_process_blocks as (
select distinct
 pcmwfge.pipeline 
,pcmwfge.process_block 
,pcmwfge.target_table 
,pcmwfge.stage_column_name 
,pcmwfge.column_name 
,pcmwfge.column_block 
,hic.content_table
,hic.content_key_column
,pcm.field_name 
from dv_pipeline_description.dvpd_pipeline_column_mapping_with_field_group_extention pcmwfge
join hash_input_columns hic on hic.table_name=pcmwfge.target_table 
								and hic.hash_column=pcmwfge.column_name 
left join dv_pipeline_description.dvpd_pipeline_column_mapping_with_field_group_extention pcm 
						     on pcm.pipeline = pcmwfge.pipeline 
							 and  pcm.target_table=hic.content_table
						     and pcm.column_name =hic.content_key_column
						     and pcmwfge.process_block=pcm.process_block 
where pcm.field_name is null						     
order by pipeline,target_table, column_block ,column_name 						     
)

### hier gehts weiter

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_WITH_FIELD_GROUPS order by pipeline,field_group,table_name;										
