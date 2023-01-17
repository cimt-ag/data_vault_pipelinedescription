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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_DRIVING_KEY_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_DRIVING_KEY_RAW as 

with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline_name
, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
from dv_pipeline_description.dvpd_dictionary dt 
)
, table_expansion as (
	select
	pipeline_name
	, json_array_elements(tables)->>'table_name'  as table_name
	, json_array_elements(tables)->'driving_keys' as driving_keys
	from data_vault_schema_basics
	)
select 
 pipeline_name 
, table_name
, json_array_elements_text(driving_keys) driving_key
from table_expansion;

comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_DRIVING_KEY_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';