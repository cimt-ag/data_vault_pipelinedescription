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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_HASH_INPUT_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_HASH_INPUT_COLUMN as 

-- HK / LK input of  business keys and dependent child keys from  the same table
select  
	 hash_target.pipeline_name
	,hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_column
	,'' content_recursion_name
	,null::integer link_parent_order
	,null::integer recursive_parent_order 
 from dv_pipeline_description.dvpd_pipeline_dv_column hash_target
join dv_pipeline_description.dvpd_pipeline_dv_column content_key on content_key.pipeline_name = hash_target .pipeline_name 
						and content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('business_key','dependent_child_key')
where hash_target.dv_column_class in ('key')
union 
-- LK input of business keys from parent tables
select 
	 link_table.pipeline_name 
	,link_table.table_name 
	,pdt.link_key_column_name 
	,content_key.table_name  content_table
	,content_key.column_name  content_column
	,recursion_name content_recursion_name
	,link_table.link_parent_order 
	,link_table.recursive_parent_order 
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent link_table
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = link_table.pipeline_name 
														and pdt.table_name =link_table .table_name 
join dv_pipeline_description.dvpd_pipeline_dv_column content_key on content_key.pipeline_name = link_table.pipeline_name
						and	content_key.table_name =link_table.link_parent_table
						and content_key.dv_column_class in ('business_key')
union
-- diff hash input from the same table
select
	 hash_target.pipeline_name
	,hash_target.table_name 
	,hash_target.column_name key_column
	,content_key.table_name content_table
	,content_key.column_name  content_column
	,'' content_recursion_name
	,null::integer link_parent_order
	,null::integer recursive_parent_order 
 from dv_pipeline_description.dvpd_pipeline_dv_column hash_target
join dv_pipeline_description.dvpd_pipeline_dv_column content_key on content_key.pipeline_name = hash_target.pipeline_name 
						and content_key.table_name =hash_target.table_name 
						and content_key.dv_column_class in ('content')
where hash_target.dv_column_class in ('diff_hash');

comment on view dv_pipeline_description.DVPD_PIPELINE_DV_HASH_INPUT_COLUMN 
is 'For every hash column in the model of a pipeline, list the table columns, that are inlcuded. Restricted on the tables, the hash column is originated';


-- select * from dv_pipeline_description.DVPD_DV_MODEL_HASH_INPUT_COLUMN order by table_name,key_column,content_column;										
