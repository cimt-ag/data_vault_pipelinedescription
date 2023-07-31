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


-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT as 

with cleansed_link_parents as (
	select 
		lower(pipeline_name ) pipeline_name
		,lower(table_name)  table_name
		,lower(parent_table_name)  link_parent_table
		,coalesce(upper(relation_name),'') relation_name
		,link_parent_order 
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
) 
select distinct 
	clp.pipeline_name 
	,clp.table_name
	,clp.link_parent_table
	,pdmt.hub_key_column_name as hub_key_column_name
	,relation_name
	,link_parent_order 
from cleansed_link_parents clp 
left join dv_pipeline_description.DVPD_PIPELINE_DV_TABLE pdmt on pdmt.table_name=clp.link_parent_table
														and pdmt.pipeline_name = clp.pipeline_name ;

comment on view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT is
 'List of parent tables of every link table including essential properties of the relation (cleansed and normalized)';													
													
-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT;