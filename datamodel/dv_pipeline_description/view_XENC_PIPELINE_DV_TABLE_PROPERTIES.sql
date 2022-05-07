--drop view if exists dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES cascade;
create or replace view dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES as 

select 
 lower(pipeline_name) as pipeline_name 
, lower(table_name) as table_name
, upper(xenc_content_hash_column_name)  as xenc_content_hash_column_name
, upper(xenc_content_salted_hash_column_name) as xenc_content_salted_hash_column_name
, lower(xenc_content_table_name) as xenc_content_table_name
, upper(xenc_encryption_key_column_name) as xenc_encryption_key_column_name
, upper(xenc_encryption_key_index_column_name) as xenc_encryption_key_index_column_name
from dv_pipeline_description.xenc_pipeline_dv_table_properties_raw
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE ;