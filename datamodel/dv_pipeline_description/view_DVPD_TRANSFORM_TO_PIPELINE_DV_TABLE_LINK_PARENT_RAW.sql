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
	, json_array_elements(tables)->'recursive_parents' as recursive_parents
	from data_vault_schema_basics
	)
,  link_parent_tables as (
	select
	pipeline_name
	,  table_name
	, json_array_elements_text(link_parent_tables) as parent_table_name
	, false is_recursive_relation
	, null::text recursion_name
	,row_number() over (PARTITION BY pipeline_name,table_name) as keep_parent_order -- must onyl exist to provide originalarray order in resulset
	from table_expansion
	)	
,  link_parent_tables_with_order as (
	select pipeline_name
			,table_name
			,parent_table_name
			,is_recursive_relation
			,recursion_name
			, row_number() over (partition by  pipeline_name,table_name) link_parent_order 
			, null::bigint recursive_parent_order
	from link_parent_tables
)
,  recursive_parent_tables as (
	select
		pipeline_name
		,  table_name
		, json_array_elements(recursive_parents)->>'table_name' as parent_table_name
		, true is_recursive_relation
		, json_array_elements(recursive_parents)->>'recursion_name' as recursion_name
		,row_number() over (PARTITION BY pipeline_name,table_name) as keep_parent_order -- must only exist to provide originalarray order in resulset
	from table_expansion
	)	
,recursive_parent_tables_with_order as (
	select pipeline_name
		,table_name
		,parent_table_name
		,is_recursive_relation
		,recursion_name
		, null::bigint link_parent_order 
		, row_number() over (partition by  pipeline_name,table_name) recursive_parent_order
		from  recursive_parent_tables
)
select * from link_parent_tables_with_order
union
select * from  recursive_parent_tables_with_order;
