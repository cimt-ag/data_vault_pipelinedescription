--drop function XENC_LOAD_PIPELINE_TO_RAW(varchar);
create or replace function dv_pipeline_description.XENC_LOAD_PIPELINE_TO_RAW(
   pipeline_to_load varchar
)
returns boolean
language plpgsql    
as 
$$
begin
	
	/* Load json scripts into relational raw model */
truncate table dv_pipeline_description.xenc_pipeline_dv_table_properties_raw ;

insert
	into
	dv_pipeline_description.xenc_pipeline_dv_table_properties_raw
(
 pipeline_name,
	table_name,
	xenc_content_hash_column_name,
	xenc_content_salted_hash_column_name,
	xenc_content_table_name,
	xenc_encryption_key_column_name,
	xenc_encryption_key_index_column_name,
	xenc_table_key_column_name)
select
	pipeline_name,
	table_name,
	xenc_content_hash_column_name,
	xenc_content_salted_hash_column_name,
	xenc_content_table_name,
	xenc_encryption_key_column_name,
	xenc_encryption_key_index_column_name,
	xenc_table_key_column_name
from
	dv_pipeline_description.xenc_transform_to_pipeline_dv_table_properties_raw;


return true;

end;
$$;
