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


-- DROP TABLE dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES_RAW cascade;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES_RAW (
	meta_inserted_at timestamp default current_timestamp,
	pipeline_name text NULL,
	field_name text NULL,
	field_type text NULL,
	field_position int NULL,
	parsing_expression text NULL,
	needs_encryption boolean null,
	field_comment text NULL
);

comment on table dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES_RAW is
 'Fields of the pipeline and their basic properties. raw = exact copy from dvpd document';