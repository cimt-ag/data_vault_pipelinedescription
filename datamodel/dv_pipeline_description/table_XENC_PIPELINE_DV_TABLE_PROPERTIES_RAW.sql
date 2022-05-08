
-- DROP TABLE dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES_RAW cascade;

CREATE TABLE dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES_RAW (
	meta_inserted_at timestamp default now()
	,pipeline_name text NULL
	,table_name text NULL
	,xenc_content_hash_column_name  text NULL
	,xenc_content_salted_hash_column_name  text NULL
	,xenc_content_table_name text NULL
	,xenc_encryption_key_column_name  text NULL
	,xenc_encryption_key_index_column_name  text NULL
	,xenc_table_key_column_name  text NULL
);