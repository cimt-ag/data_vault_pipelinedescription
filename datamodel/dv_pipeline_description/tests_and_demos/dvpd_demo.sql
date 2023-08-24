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

/* Basic queries to the dictionary */

select * from dv_pipeline_description.dvpd_dv_model_table 
order by table_name ;

select * from dv_pipeline_description.dvpd_dv_model_column ddmc 
order by table_name,column_block ,column_name ;
 
select * from dv_pipeline_description.dvpd_source_field_mapping dsfm 
order by pipeline ,field_name ;

select * from  dv_pipeline_description.dvpd_pipeline_leaf_and_process_table
order by pipeline ,leaf_table,table_to_process ;
 
/* Stage table column structure */

select distinct 
	plap.pipeline 
	,case when mc.column_name = sfm.field_name or sfm.field_name is null 
												then mc.column_name
											   else mc.column_name||'__X__'|| 	sfm.field_name end stage_column_name
	,mc.column_type 
	,mc.column_block 
	,sfm.field_name 
	,sfm.field_type 
	,sfm.needs_encryption 
from dv_pipeline_description.dvpd_pipeline_leaf_and_process_table plap 
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name = plap.table_to_process 
													 and mc.column_class not in ('meta')
left join dv_pipeline_description.dvpd_source_field_mapping sfm on sfm.table_name = plap.table_to_process 	
														  and sfm.column_name =mc.column_name 
order by pipeline,mc.column_block ,2 
														  




											 )
											 
 /* Determine solutions to fill satellites and links without 

with target_leafs as (
	select distinct 
		pipeline 
		,table_name as table_name
		,table_name as leaf_table
		from (
			select  distinct
			pipeline,
			 table_name
			from dv_pipeline_description.dvpd_field_mapping dfm  
		) direct_mapped_tables
)
, sat_parents as (
select tl.pipeline 
,tb.satellite_parent  as table_name 
,leaf_table
from target_leafs tl
join dv_pipeline_description.dvpd_dv_model_table_basics tb on tb.pipeline =tl.pipeline
										 and tb.table_name=tl.table_name
)
, 
select *
from sat_parents
union
select *
from target_leafs
union
select *
from link_parents;

select * from dvpd_processing_plan_per_leaf_table
order by leaf_table; 

