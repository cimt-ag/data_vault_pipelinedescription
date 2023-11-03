-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================



-- DROP TABLE dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES_RAW cascade;

CREATE TABLE dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES_RAW (
	meta_inserted_at timestamp default current_timestamp
	,pipeline_name text NULL
	,table_name text NULL
	,xenc_content_hash_column_name  text NULL
	,xenc_content_salted_hash_column_name  text NULL
	,xenc_content_table_name text NULL
	,xenc_encryption_key_column_name  text NULL
	,xenc_encryption_key_index_column_name  text NULL
	,xenc_table_key_column_name  text NULL
);

--CREATE INDEX xenc_pipeline_dv_table_properties_raw_pipeline_name_idx ON dv_pipeline_description.xenc_pipeline_dv_table_properties_raw (pipeline_name,table_name);

comment on table dv_pipeline_description.XENC_PIPELINE_DV_TABLE_PROPERTIES_RAW is
 'Encryption properties for tables of the pipeline. raw = exact copy from dvpd document';