--drop view if exists dv_pipeline_description.DVPD_DV_MODEL_HASH_INPUT_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_DV_MODEL_HASH_INPUT_COLUMN as 

select
	 hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_column
	,'' hierarchy_key_suffix
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
where hash_target.dv_column_class in ('key')
union 
select 
	 link_table.table_name 
	,dmt.link_key_column_name 
	,content_key.table_name  content_table
	,content_key.column_name  content_column
	,hierarchy_key_suffix
from dv_pipeline_description.dvpd_dv_model_link_parent link_table
join dv_pipeline_description.dvpd_dv_model_table dmt on dmt.table_name =link_table .table_name 
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =link_table.parent_table_name 
						and content_key.dv_column_class in ('business_key')
union
select
	 hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_column
	,'' hierarchy_key_suffix
 from dv_pipeline_description.dvpd_dv_model_column hash_target
join dv_pipeline_description.dvpd_dv_model_column content_key on content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('content')
where hash_target.dv_column_class in ('diff_hash');

comment on view dv_pipeline_description.DVPD_DV_MODEL_HASH_INPUT_COLUMN 
is 'For every hash column in the model, list the table columns, that are inlcuded. Restricted on the tables, the hash column is originated';


-- select * from dv_pipeline_description.DVPD_DV_MODEL_HASH_INPUT_COLUMN order by table_name,key_column,content_column;										
