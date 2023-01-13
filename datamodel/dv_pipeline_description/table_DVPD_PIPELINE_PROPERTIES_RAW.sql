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


-- DROP TABLE dv_pipeline_description.dvpd_pipeline_properties_raw cascade;

CREATE TABLE dv_pipeline_description.dvpd_pipeline_properties_raw (
	meta_inserted_at timestamp default now(),
	pipeline_name text not NULL,
	dvpd_version text NULL,
	pipeline_revision_tag text NULL,
	pipeline_comment text NULL,
	record_source_name_expression text NULL,
	fetch_module_name text NULL,
	model_profile_name text NULL,
	primary key (pipeline_name)
);