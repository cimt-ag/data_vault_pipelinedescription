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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_LINK_PARENT_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_LINK_PARENT_RAW as 

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
	, json_array_elements(tables)->'link_parent_tables' as link_parent_tables
	from data_vault_schema_basics
	)
,  simple_link_parent_tables as (
	select
	pipeline_name
	,  table_name
	, json_array_elements_text(link_parent_tables) as parent_table_name
	, null::varchar as relation_name
	, null::varchar as hub_key_column_name_in_link
	, 0 as link_parent_order
	from table_expansion
		)
,  full_link_parent_tables as (
	select
	pipeline_name
	,  table_name
	, json_array_elements(link_parent_tables)->>'table_name' as parent_table_name
	, json_array_elements(link_parent_tables)->>'relation_name' as relation_name
	, json_array_elements(link_parent_tables)->>'hub_key_column_name_in_link' as hub_key_column_name_in_link
	, 0 as link_parent_order
	from table_expansion
)
select * from simple_link_parent_tables where not	dv_pipeline_description.f_is_json(parent_table_name)
union 
select * from full_link_parent_tables where not dv_pipeline_description.f_is_json(parent_table_name) and parent_table_name  is not null;



comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_LINK_PARENT_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';