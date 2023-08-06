-- Field expansion
with youngest_pipeline as ( 
select lower(pipeline_name) pipeline_name
from dv_pipeline_description.dvpd_dictionary
where meta_inserted_at = (Select max(meta_inserted_at ) from dv_pipeline_description.dvpd_dictionary)
)
select
	pipeline_name,
	field_name,
	table_name,
	column_name,
	relation_name
from
	dv_pipeline_description.dvpd_pipeline_field_target_expansion
join youngest_pipeline using (pipeline_name) 	
order by pipeline_name,field_name,table_name ,relation_name  ;

-- Tables and columns
with youngest_pipeline as ( 
select lower(pipeline_name) pipeline_name
from dv_pipeline_description.dvpd_dictionary
where meta_inserted_at = (Select max(meta_inserted_at ) from dv_pipeline_description.dvpd_dictionary)
)
select
	pipeline_name,
	table_name,
	column_name
from
	dv_pipeline_description.dvpd_pipeline_dv_column
join youngest_pipeline using (pipeline_name) 	
order by pipeline_name,table_name ,column_name ;


--Process plan
with youngest_pipeline as ( 
select lower(pipeline_name) pipeline_name
from dv_pipeline_description.dvpd_dictionary
where meta_inserted_at = (Select max(meta_inserted_at ) from dv_pipeline_description.dvpd_dictionary)
)
select
	pipeline_name,
	table_name,
	table_stereotype,
	relation_to_process,
	relation_origin
from
	dv_pipeline_description.dvpd_pipeline_process_plan
join youngest_pipeline using (pipeline_name)	
--where pipeline_name ~ 'test_\d{3}_.*'	
order by pipeline_name ,table_name, relation_to_process;


--Essential mapping
with youngest_pipeline as ( 
select lower(pipeline_name) pipeline_name
from dv_pipeline_description.dvpd_dictionary
where meta_inserted_at = (Select max(meta_inserted_at ) from dv_pipeline_description.dvpd_dictionary)
)
select
	pipeline_name,
	table_name,
	table_stereotype,
	relation_to_process,
	column_name,
	stage_column_name,
	field_name,
	field_relation_name
from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping
join youngest_pipeline using (pipeline_name)
--where pipeline_name ~ '.+st_\d{3}_.*'	
order by pipeline_name ,table_name, relation_to_process,column_block,column_name;

--Hash input fields
with youngest_pipeline as ( 
select lower(pipeline_name) pipeline_name
from dv_pipeline_description.dvpd_dictionary
where meta_inserted_at = (Select max(meta_inserted_at ) from dv_pipeline_description.dvpd_dictionary)
)
select
	pipeline_name
	,relation_of_hash
	,stage_column_name
	,field_name
	,prio_in_key_hash
	,prio_in_diff_hash
	,content_column
	,link_parent_order
from dv_pipeline_description.dvpd_pipeline_stage_hash_input_field
join youngest_pipeline using (pipeline_name)
--where pipeline_name ~ '.+st_\d{3}_.*'	
order by pipeline_name ,relation_of_hash,stage_column_name,field_name;
