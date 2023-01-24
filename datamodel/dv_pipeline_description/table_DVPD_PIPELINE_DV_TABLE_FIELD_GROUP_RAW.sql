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

-- DROP TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_FIELD_GROUP_RAW;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_FIELD_GROUP_RAW (
	meta_inserted_at timestamp default now(),
	pipeline_name text NULL,
	table_name text NULL,
	field_group text NULL
);

comment on table dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_FIELD_GROUP_RAW is
 'Field group array of every table of the pipeline. raw = exact copy from dvpd document';