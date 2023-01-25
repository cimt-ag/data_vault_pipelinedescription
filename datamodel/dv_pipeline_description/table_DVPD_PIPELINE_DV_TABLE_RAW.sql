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


-- DROP TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_RAW cascade;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_RAW (
	meta_inserted_at timestamp default now(),
	pipeline_name varchar(255) NULL,
	schema_name varchar(255) NULL,
	table_name varchar(255) NULL,
	stereotype varchar(255) NULL,
	hub_key_column_name varchar(255) NULL,
	link_key_column_name varchar(255) NULL,
	diff_hash_column_name varchar(255) NULL,
	satellite_parent_table varchar(255) NULL,
	is_link_without_sat varchar(255) NULL,
	is_enddated varchar(255) NULL,
	model_profile_name varchar(255) NULL,
	table_content_comment varchar(3000) NULL
);

comment on table dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_RAW is
 'Tables of the pipeline. raw = exact copy from dvpd document';