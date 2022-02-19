drop view if exists dv_pipeline_description.DVPD_DV_MODEL_KEY_INPUT_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_DV_MODEL_KEY_INPUT_COLUMN as 

select
	 hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
where hash_target.dv_column_class in ('key')
union all
select 
	 link_parent.table_name 
	,link_parent.parent_hub_key_column_name key_column
	,content_key.table_name  content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_link_parent link_parent
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =link_parent.parent_table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
union all
select
	 hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_key_column
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('content')
where hash_target.dv_column_class in ('diff_hash');



-- select * from dv_pipeline_description.DVPD_DV_MODEL_KEY_INPUT_COLUMN order by table_name,key_column;										
