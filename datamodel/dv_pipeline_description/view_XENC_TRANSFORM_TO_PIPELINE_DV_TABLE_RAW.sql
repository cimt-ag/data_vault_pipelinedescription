--drop view if exists dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_DV_TABLE_PROPERTIES_RAW cascade;
create or replace view dv_pipeline_description.XENC_TRANSFORM_TO_PIPELINE_DV_TABLE_PROPERTIES_RAW as 

with data_vault_schema_basics as (
	select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
	from dv_pipeline_description.dvpd_dictionary dt 
),
json_parsing as (
select
pipeline_name
, json_array_elements(tables)->>'table_name'  as table_name
, json_array_elements(tables)->>'xenc_content_hash_column_name' as xenc_content_hash_column_name
, json_array_elements(tables)->>'xenc_content_salted_hash_column_name' as xenc_content_salted_hash_column_name
, json_array_elements(tables)->>'xenc_content_table_name' as xenc_content_table_name
, json_array_elements(tables)->>'xenc_encryption_key_column_name' as xenc_encryption_key_column_name
, json_array_elements(tables)->>'xenc_encryption_key_index_column_name' as xenc_encryption_key_index_column_name
, json_array_elements(tables)->>'xenc_table_key_column_name' as xenc_table_key_column_name
from data_vault_schema_basics
)
select * from json_parsing 
where xenc_content_table_name  is not null or xenc_encryption_key_index_column_name is not null;


